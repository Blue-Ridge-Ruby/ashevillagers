class TownHallController < ApplicationController
  before_action :authenticate_steward!

  layout "town_hall"

  private

  def current_steward
    @current_steward ||= Steward.find_by(id: session[:steward_id])
  end

  def authenticate_steward!
    unless current_steward
      redirect_to new_town_hall_session_path, alert: "Please sign in."
    end
  end
end
