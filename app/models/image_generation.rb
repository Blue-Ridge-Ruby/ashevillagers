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
    best_rgb = Okmain.colors(raw_image_path) # extract main colors as rgb triples
      .max_by { Okmain::Oklab.srgb8_to_oklch(*it)[1] } # pick the highest-chroma one
    best_oklab = Okmain::Oklab.srgb8_to_oklab(*best_rgb)
    TailwindColor.bolds(600)
      .min_by { distance_3d_sq(best_oklab, it.oklab) }
      .hue
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

  private

  def distance_3d_sq(a, b) = (a[0] - b[0])**2 + (a[1] - b[1])**2 + (a[2] - b[2])**2
end
