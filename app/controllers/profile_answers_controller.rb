class ProfileAnswersController < ApplicationController
  before_action :authenticate_villager!

  def update
    profile = current_villager.profile
    @answer = profile.profile_answers.find(params[:id])

    if @answer.update(answer_params) && @answer.answer.present?
      @answer.create_image_generation! if @answer.image_generation.blank?
      ImageGenerationJob.perform_later(@answer.image_generation)
      redirect_to edit_profile_path
    else
      @answer.errors.add(:answer, "can't be blank") if @answer.answer.blank?
      @profile = profile
      @questions = ProfileQuestion.active
      @phase = :question
      render template: "profiles/edit", status: :unprocessable_entity
    end
  end

  private

  def answer_params
    params.require(:profile_answer).permit(:answer)
  end
end
