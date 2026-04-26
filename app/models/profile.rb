class Profile < ApplicationRecord
  SOCIAL_LINKS = %i[twitter_url bluesky_url mastodon_url linkedin_url website_url].freeze

  belongs_to :villager
  belongs_to :selected_image_generation, class_name: "ImageGeneration", optional: true

  has_one_attached :reference_photo
  has_many :profile_answers, dependent: :destroy
  has_many :image_generations, through: :profile_answers
  accepts_nested_attributes_for :profile_answers

  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :acceptable_reference_photo
  validate :selected_image_belongs_to_this_profile

  def to_param
    "#{id}-#{first_name}-#{last_name}".parameterize
  end

  def has_social_links?
    SOCIAL_LINKS.any? { |attr| self[attr].present? }
  end

  def answer_for(question)
    profile_answers.detect { |pa| pa.profile_question_id == question.id }
  end

  # Build or find a ProfileAnswer for each active question, for form rendering
  def ensure_answers_for(questions)
    questions.each do |q|
      profile_answers.find_or_initialize_by(profile_question: q)
    end
  end

  # Suggest initial name from vilalger if blank
  def suggest_name_from_villager!
    self.first_name ||= villager&.first_name
    self.last_name ||= villager&.last_name
  end

  def next_unanswered_question(questions = ProfileQuestion.active)
    questions.find { answer_for(it)&.answer.blank? }
  end

  def last_answer(questions = ProfileQuestion.active)
    questions.all.filter_map do |q|
      a = answer_for(q)
      next nil unless a&.answer.present?
      a
    end.last
  end

  def finalized?
    selected_image_generation_id.present? && first_name.present? && last_name.present?
  end

  def current_phase(questions = ProfileQuestion.active)
    return :photo unless reference_photo.attached?
    return :question if next_unanswered_question(questions)
    return :finalize unless finalized?
    :complete
  end

  private

  def acceptable_reference_photo
    return unless reference_photo.attached?
    errors.add(:reference_photo, "must be a PNG, JPEG, or WebP") unless reference_photo.content_type.in?(%w[image/png image/jpeg image/webp])
    errors.add(:reference_photo, "must be less than 5MB") if reference_photo.byte_size > 5.megabytes
  end

  def selected_image_belongs_to_this_profile
    return unless selected_image_generation_id.present?
    return unless selected_image_generation
    if selected_image_generation.profile_answer&.profile_id != id
      errors.add(:selected_image_generation, "must belong to this profile")
    elsif !selected_image_generation.image.attached?
      errors.add(:selected_image_generation, "is still generating")
    end
  end
end
