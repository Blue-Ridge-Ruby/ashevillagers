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
      prepare_form
    end
  end

  def create
    @profile = current_villager.build_profile(profile_params)

    if @profile.save
      redirect_to edit_profile_path, notice: "Profile created."
    else
      prepare_form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = current_villager.profile || current_villager.build_profile
    @profile.suggest_name_from_villager! if @profile.new_record?
    prepare_form
  end

  def update
    @profile = current_villager.profile || current_villager.build_profile

    if @profile.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile updated."
    else
      prepare_form
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def prepare_form
    @questions = ProfileQuestion.active
    @profile.ensure_answers_for(@questions)
  end

  def profile_params
    params.require(:profile).permit(
      :first_name, :last_name,
      :twitter_url, :bluesky_url, :mastodon_url, :linkedin_url, :website_url,
      :photo,
      profile_answers_attributes: %i[id profile_question_id answer]
    )
  end
end
