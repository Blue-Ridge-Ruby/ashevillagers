class ProfileAnswer < ApplicationRecord
  include Configuration::Configurable

  belongs_to :profile
  belongs_to :profile_question
  has_one :image_generation, dependent: :destroy

  delegate :question, to: :profile_question

  configure_with :model_for_job_title

  lazy_attribute :job_title, -> {
    return nil unless answer.present?
    Configured.RubyLLM.chat(model: model_for_job_title)
      .with_instructions(profile_question.llm_prompt)
      .ask(answer)
      .content
  }
end
