class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_steward, :current_villager

  private

  def current_steward
    nil
  end

  def current_villager
    return @current_villager if defined?(@current_villager)
    @current_villager = session[:villager_id] && Villager.find_by(id: session[:villager_id])
  end

  def authenticate_villager!
    unless current_villager
      redirect_to new_session_path, alert: "Please sign in."
    end
  end
end
