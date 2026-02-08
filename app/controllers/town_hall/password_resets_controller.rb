module TownHall
  class PasswordResetsController < ApplicationController
    layout "town_hall"

    def new
    end

    def create
      steward = Steward.find_by(email: params[:email])
      StewardMailer.password_reset(steward).deliver_later if steward

      redirect_to new_town_hall_session_path, notice: "If that email exists, a reset link has been sent."
    end

    def edit
      @steward = Steward.find_by_token_for(:password_reset, params[:token])

      unless @steward
        redirect_to new_town_hall_password_reset_path, alert: "Invalid or expired reset link."
      end
    end

    def update
      @steward = Steward.find_by_token_for(:password_reset, params[:token])

      unless @steward
        redirect_to new_town_hall_password_reset_path, alert: "Invalid or expired reset link."
        return
      end

      if @steward.update(password: params[:password], password_confirmation: params[:password_confirmation])
        redirect_to new_town_hall_session_path, notice: "Password updated. Please sign in."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
