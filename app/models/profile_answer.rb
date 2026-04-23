class ProfileAnswer < ApplicationRecord
  include Configuration::Configurable

  belongs_to :profile
  belongs_to :profile_question
  has_one :image_generation, dependent: :destroy

  delegate :question, to: :profile_question

  configure_with :model_for_job_title

  def job_title
    return nil unless answer.present?
    attributes["job_title"].presence || begin
      self.job_title = title = get_job_title
      save if persisted?
      title
    end
  end

  def regenerate_job_title!
    self.job_title = nil
    job_title
  end

  private

  def get_job_title
    Configured.RubyLLM.chat(model: model_for_job_title)
      .with_instructions(profile_question.llm_prompt)
      .ask(answer)
      .content
  end
end
