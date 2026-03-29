module TownHall
  class ProfilesController < TownHallController
    def edit
      @steward = current_steward
    end

    def update
      @steward = current_steward

      if @steward.update(profile_params)
        redirect_to edit_town_hall_profile_path, notice: "Profile updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:steward).permit(:first_name, :last_name, :email, :mobile_phone, :password, :password_confirmation).tap do |p|
        p.delete(:password) if p[:password].blank?
        p.delete(:password_confirmation) if p[:password].blank?
      end
    end
  end
end
