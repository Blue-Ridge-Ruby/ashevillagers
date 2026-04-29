class ImageGeneration < ApplicationRecord
  include Configuration::Configurable

  # Note: prompt_for_image_generation should include %{animal} and %{job}
  configure_with :animals_popular, :animals_other, model: :model_for_image_generation, prompt_template: :prompt_for_image_generation

  belongs_to :profile_answer
  has_one :profile, through: :profile_answer

  has_one_attached :image, dependent: false
  has_one_attached :cropped, dependent: false do |attachable|
    attachable.variant :card, resize_to_limit: [600, 1000], format: :webp, saver: {quality: 90, smart_subsample: true}
  end
  has_one_attached :generated_from, dependent: false

  before_save :ensure_animal

  def source_photo = profile.reference_photo
  def job = profile_answer.job_title

  lazy_attribute :prompt, -> {
    raise "Missing villager's job" unless job.present?
    raise "Missing prompt_for_image_generation configuration" unless prompt_template.present?
    prompt_template % {animal:, job:}
  }

  lazy_attribute :animal, -> { (self.class.animals - (profile&.image_generations&.pluck(:animal) || [])).sample }

  lazy_attribute :hue, -> {
    compute_hue(attachment: :image, debug: true) => value, {found:}
    found ? value : compute_hue(attachment: :cropped)
  }

  def title = "#{animal} #{job}"

  def color = (TailwindColor[hue] || TailwindColor.sky).at(600)

  def reset!(animal: false)
    self.prompt = nil
    self.hue = nil
    image.detach
    cropped.detach
    generated_from.detach
    self.animal = nil if animal
    save!
  end

  # retries once if crop removed little, indicating too much background texture
  def ensure_and_crop_image!(retries_allowed: 1)
    return image if image.attached?
    Rails.logger.info(self.class.name) { "Retrying image generation" } if retries_allowed == 0
    painted = generate_image
    painted_bytes = painted.to_blob
    cropped_io = self.class.crop_to_figure(painted_bytes) do |crop|
      retries_allowed == 0 || (crop[:left] > 10 && crop[:top] > 10)
    end
    return ensure_and_crop_image!(retries_allowed: retries_allowed - 1) unless cropped_io
    generated_from.attach(source_photo.blob)
    cropped.attach(
      io: cropped_io,
      filename: "cropped.png",
      content_type: "image/png",
      identify: false
    )
    _, extension = painted.mime_type.split(/^image\//)
    image.attach(
      io: StringIO.new(painted.to_blob),
      filename: "original.#{extension || "png"}",
      content_type: painted.mime_type,
      identify: !extension
    )
  end

  def generate_image
    raise "Missing source photo" unless source_photo.present?
    painted = Configured.RubyLLM.paint(prompt, model:, with: source_photo.variant(:llm).blob)
    @painted = painted if Rails.env.local? # for inspection in dev console
    painted
  end

  if Rails.env.development?
    def preview!(attachment = :image, variant = false)
      raise "Missing attachment #{attachment}" unless send(attachment).send(*(variant ? [:variant, variant] : :itself)).present?
      system("open", "-a", "Preview", raw_image_path(attachment, variant))
    end
  end

  # WARNING: Depends on us continuing to use config.active_storage.service = :local
  def raw_image_path(attachment = :image, variant = false)
    blob = send(attachment).send(*(variant ? [:variant, variant] : :itself)).blob
    blob.service.path_for(blob.key)
  end

  def self.animals
    other = animals_other.split(/,\s*/)
    popular = animals_popular.split(/,\s*/)
    [*other, *(popular * [(other.size / popular.size), 1].max)]
  end

  # Returns a StringIO of the cropped PNG bytes
  # Optional block receives the detected crop plan, can return false to cancel
  def self.crop_to_figure(source, margin: 12, threshold: 5, background: nil)
    source = case source
    in ActiveStorage::Blob => blob then Vips::Image.new_from_file(blob.service.path_for(blob.key))
    in String => bytes then Vips::Image.new_from_buffer(bytes, "")
    end
    source = source.flatten(background: background || [255, 255, 255]) if source.has_alpha?

    left, top, width, height = source.find_trim(threshold: threshold, background: background)
    # Image generation usually visually centers the image even when it's unbalanced,
    # so apply margins and mirror left and right crop.
    right = (source.width - width - left - margin).clamp(0..)
    left = (left - margin).clamp(0..)
    left, width = (right > left) ? [left, source.width - left * 2] : [right, source.width - right * 2]
    # We don't care vertical centering, so just apply margins
    bottom = (source.height - height - top - margin).clamp(0..)
    top = (top - margin).clamp(0..)
    height = source.height - top - bottom
    return if block_given? && !yield({left:, top:, right:, bottom:, width:, height:})
    cropped = source.crop(left, top, width, height)
    StringIO.new(cropped.write_to_buffer(".png"))
  end

  private

  def compute_hue(attachment: :image, target_level: 600, debug: false)
    return unless send(attachment).present?
    # Utimately we will select a Tailwind hue, returning the name (e.g., "orange")
    targets = TailwindColor.bolds(600)
    # Extract main colors as rgb triples. Okmain sorts (descending) by a combination of
    # chroma and the color's prominence in the image.
    main_rgbs = Okmain.colors(raw_image_path(attachment))
    main_oklchs = main_rgbs.map { Okmain::Oklab.srgb8_to_oklch(*it) }
    # With this style of image, okmain colors almost always include an off-white and a dark
    # grayish. We exclude those with a chroma threshold and a lightness range.
    bold_oklchs = main_oklchs.select { it[1] > 0.02 && (0.4..0.9).cover?(it[0]) }
    # Map the remaining colors to the nearest (by hue angle) Tailwind hue.
    nearest_targets = bold_oklchs.map do |oklch|
      targets.min_by do |t|
        a = (t.oklch[2] - oklch[2]).abs
        (a > 180) ? 360 - a : a
      end
    end
    found = nearest_targets
      .sort_by { (it.hue == "amber") ? 1 : - 1 } # amber-600 looks fine but comes up a lot with brown fur: deprioritize
      .find { it.hue != "yellow" } # yellow-600 looks bad, and yellow-ish is too common a main color with light brown fur
    hue = found&.hue || "sky" # If an image actually is dominated by yellow/brown, sky should look complimentary.
    return hue unless debug
    [hue, {
      found:,
      colors: bold_oklchs.map { "oklch(%.3f %.3f %.3f)" % it },
      targets: nearest_targets
    }]
  end
end
