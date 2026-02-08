module TownHall
  class StewardsController < TownHallController
    def index
      @stewards = Steward.order(:last_name, :first_name)
    end

    def new
      @steward = Steward.new
    end

    def create
      @steward = Steward.new(steward_params)

      if @steward.save
        redirect_to town_hall_stewards_path, notice: "Steward added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      steward = Steward.find(params[:id])

      if steward == current_steward
        redirect_to town_hall_stewards_path, alert: "You cannot delete yourself."
      else
        steward.destroy
        redirect_to town_hall_stewards_path, notice: "Steward removed."
      end
    end

    private

    def steward_params
      params.require(:steward).permit(:email, :first_name, :last_name, :mobile_phone, :password, :password_confirmation)
    end
  end
end
