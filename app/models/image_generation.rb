class ImageGeneration < ApplicationRecord
  include Configuration::Configurable

  # Note: prompt_for_image_generation should include %{animal} and %{job}
  configure_with :animals_popular, :animals_other, model: :model_for_image_generation, prompt_template: :prompt_for_image_generation

  belongs_to :profile_answer
  has_one :profile, through: :profile_answer

  has_one_attached :image
  has_one_attached :generated_from

  before_save :ensure_animal

  def source_photo = profile.reference_photo
  def job = profile_answer.job_title

  lazy_attribute :prompt, -> {
    raise "Missing villager's job" unless job.present?
    prompt_template % {animal:, job:}
  }

  lazy_attribute :animal, -> { (self.class.animals - (profile&.image_generations&.pluck(:animal) || [])).sample }

  lazy_attribute :hue, -> {
    return unless image.present?
    # Utimately we will select a Tailwind hue, returning the name (e.g., "orange")
    targets = TailwindColor.bolds(600)
    # Extract main colors as rgb triples. Okmain sorts (descending) by a combination of
    # chroma and the color's prominence in the image.
    main_rgbs = Okmain.colors(raw_image_path)
    main_oklchs = main_rgbs.map { Okmain::Oklab.srgb8_to_oklch(*it) }
    # With this style of image, okmain colors almost always include an off-white and a dark
    # grayish. We exclude those with a chroma threshold and a lightness range.
    bold_oklchs = main_oklchs.select { it[1] > 0.02 && (0.4..0.9).cover?(it[0]) }
    # Map the remaining colors to the nearest (by hue angle) Tailwind hue.
    nearest_hues = bold_oklchs.map do |oklch|
      targets.min_by do |t|
        a = (t.oklch[2] - oklch[2]).abs
        (a > 180) ? 360 - a : a
      end.hue
    end
    # yellow-600 just isn't pretty, and yellow-ish is too common a main color with all the
    # light brown fur in these designs. If an image actually is dominated by yellow/brown,
    # sky should look complimentary.
    nearest_hues.find { it != "yellow" } || "sky"
  }

  def title = "#{animal} #{job}"

  def color = (TailwindColor[hue] || TailwindColor.sky).at(600)

  def ensure_image!
    return image if image.present?
    raise "Missing source photo" unless source_photo.present?
    raise "Missing prompt_for_image_generation configuration" unless prompt.present?
    painted = Configured.RubyLLM.paint(prompt, model:, with: source_photo.blob)
    @painted = painted if Rails.env.local? # for inspection in dev console
    generated_from.attach(source_photo.blob)
    image.attach(
      io: StringIO.new(painted.to_blob),
      filename: "profile.png",
      content_type: painted.mime_type,
      identify: false
    )
  end

  if Rails.env.development?
    def preview!
      raise "Missing image" unless image.blob.present?
      system("open", "-a", "Preview", raw_image_path)
    end
  end

  # WARNING: Depends on us continuing to use config.active_storage.service = :local
  def raw_image_path = image.blob.service.path_for(image.blob.key)

  def self.animals
    other = animals_other.split(",")
    popular = animals_popular.split(",")
    [*other, *(popular * [(other.size / popular.size), 1].max)]
  end
end
