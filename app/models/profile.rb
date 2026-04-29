class Profile < ApplicationRecord
  SocialLink = Data.define(:name, :icon_default, :label, :placeholder) do
    def attribute = "#{name}_url"

    def icon(attrs)
      iname, iattrs = icon_default
      [iname, {**iattrs, **attrs}]
    end
  end

  SOCIAL_LINKS = [
    SocialLink.new(:website, ["house", style: "fill"], "Website or Blog", "https://yoursite.com"),
    SocialLink.new(:twitter, ["twitter-logo", style: "fill"], "X/Twitter", "https://x.com/yourhandle"),
    SocialLink.new(:bluesky, ["butterfly", style: "fill"], "Bluesky", "https://bsky.app/profile/yourhandle"),
    SocialLink.new(:mastodon, ["mastodon-logo", style: "fill"], "Mastodon", "https://ruby.social/@yourhandle"),
    SocialLink.new(:linkedin, ["linkedin-logo", style: "fill"], "LinkedIn", "https://www.linkedin.com/in/yourhandle/"),
    SocialLink.new(:github, ["github-logo", style: "fill"], "GitHub", "https://github.com/yourhandle")
  ].freeze
  belongs_to :villager
  belongs_to :selected_image_generation, class_name: "ImageGeneration", optional: true

  has_one_attached :reference_photo do |attachable|
    attachable.variant :llm, resize_to_limit: [1024, 1024], format: :jpeg
  end
  has_many :profile_answers, dependent: :destroy
  has_many :image_generations, through: :profile_answers
  accepts_nested_attributes_for :profile_answers

  scope :finalized, -> { where.not(selected_image_generation_id: nil) }

  # Just require one name
  validates :first_name, presence: true, unless: -> { last_name.present? }
  validates :last_name, presence: true, unless: -> { first_name.present? }
  validate :acceptable_reference_photo
  validate :selected_image_belongs_to_this_profile

  def to_param
    [id, first_name, last_name].compact_blank.join("-").parameterize
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
    selected_image_generation_id.present?
  end

  def current_phase(questions = ProfileQuestion.active)
    return :complete if finalized?
    return :photo unless reference_photo.attached?
    return :question if next_unanswered_question(questions)
    :finalize
  end

  def social_links
    SOCIAL_LINKS.filter_map do |link|
      href = attributes[link.attribute]
      next nil unless href.present?
      [link, href]
    end
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
