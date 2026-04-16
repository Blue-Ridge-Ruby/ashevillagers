class Profile < ApplicationRecord
  SOCIAL_LINKS = %i[twitter_url bluesky_url mastodon_url linkedin_url website_url].freeze

  belongs_to :villager

  has_one_attached :photo
  has_many :profile_answers, dependent: :destroy
  accepts_nested_attributes_for :profile_answers

  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :acceptable_photo

  def to_param
    "#{id}-#{first_name}-#{last_name}".parameterize
  end

  def has_social_links?
    SOCIAL_LINKS.any? { |attr| self[attr].present? }
  end

  def answer_for(question)
    profile_answers.detect { |pa| pa.profile_question_id == question.id }&.answer
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

  private

  def acceptable_photo
    return unless photo.attached?
    errors.add(:photo, "must be a PNG, JPEG, or WebP") unless photo.content_type.in?(%w[image/png image/jpeg image/webp])
    errors.add(:photo, "must be less than 5MB") if photo.byte_size > 5.megabytes
  end
end
