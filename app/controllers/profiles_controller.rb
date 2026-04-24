class ProfilesController < ApplicationController
  before_action :authenticate_villager!, only: %i[new create edit update]

  def index
    @profiles = Profile.includes(:villager, :profile_answers, photo_attachment: :blob)
      .where.not(first_name: [nil, ""])
      .order(:last_name, :first_name)
  end

  def show
    @profile = Profile.includes(profile_answers: :profile_question).find(params[:id])
    @questions = ProfileQuestion.active
  end

  def new
    if current_villager.profile
      redirect_to edit_profile_path
    else
      @profile = current_villager.build_profile
      @profile.suggest_name_from_villager!
    end
  end

  def create
    @profile = current_villager.build_profile
    @profile.suggest_name_from_villager!

    if @profile.save
      redirect_to edit_profile_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = current_villager.profile
    redirect_to(new_profile_path) and return unless @profile

    @questions = ProfileQuestion.active
    ensure_answer_records if @profile.photo.attached?
    @phase = @profile.current_phase(@questions)
  end

  def update
    @profile = current_villager.profile
    @questions = ProfileQuestion.active

    if params.dig(:profile, :photo).present?
      update_phase(photo_params, :photo)
    else
      update_phase(finalize_params, @profile.current_phase(@questions))
    end
  end

  private

  def update_phase(attrs, phase_on_failure)
    if @profile.update(attrs)
      redirect_to edit_profile_path
    else
      @phase = phase_on_failure
      render :edit, status: :unprocessable_entity
    end
  end

  # Pre-persist ProfileAnswer rows for stable ids in the per-question form.
  def ensure_answer_records
    @questions.each do |q|
      @profile.profile_answers.find_or_create_by(profile_question: q)
    end
    @profile.profile_answers.reload
  end

  def photo_params
    params.require(:profile).permit(:photo)
  end

  def finalize_params
    params.require(:profile).permit(:first_name, :last_name, :selected_image_generation_id, *Profile::SOCIAL_LINKS)
  end
end
