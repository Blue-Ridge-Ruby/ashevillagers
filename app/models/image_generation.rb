class ImageGeneration < ApplicationRecord
  include Configuration::Configurable

  # Note: prompt_for_image_generation should include %{animal} and %{job}
  configure_with :animals_popular, :animals_other, model: :model_for_image_generation, prompt_template: :prompt_for_image_generation

  belongs_to :profile_answer
  has_one :profile, through: :profile_answer

  has_one_attached :image

  def source_photo = profile.photo
  def job = profile_answer.job_title

  def prompt
    attributes["prompt"].presence || begin
      self.prompt = p = (prompt_template % {animal:, job:})
      save if persisted?
      p
    end
  end

  def animal
    attributes["animal"].presence || begin
      self.animal = a = (self.class.animals - (profile&.image_generations&.pluck(:animal) || [])).sample
      save if persisted?
      a
    end
  end

  def self.animals
    other = animals_other.split(",")
    popular = animals_popular.split(",")
    [*other, *(popular * [(other.size / popular.size), 1].max)]
  end
end
