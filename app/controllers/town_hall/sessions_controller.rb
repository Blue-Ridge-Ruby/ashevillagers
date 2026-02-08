module TownHall
  class SessionsController < ApplicationController
    layout "town_hall"

    def new
    end

    def create
      steward = Steward.authenticate_by(email: params[:email], password: params[:password])

      if steward
        session[:steward_id] = steward.id
        redirect_to town_hall_stewards_path, notice: "Signed in successfully."
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:steward_id)
      redirect_to new_town_hall_session_path, notice: "Signed out."
    end
  end
end
