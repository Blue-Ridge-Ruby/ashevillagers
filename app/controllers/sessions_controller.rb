class SessionsController < ApplicationController
  def new
  end

  def create
    villager = Villager.where("LOWER(email) = ?", params[:email].to_s.strip.downcase).first

    if villager
      VillagerMailer.login_link(villager).deliver_later
    end

    # Always show the same message to avoid leaking whether the email exists
    redirect_to new_session_path, notice: "If that email is in our system, you'll receive a login link shortly."
  end

  def callback
    @token = params[:token]

    if request.post?
      villager = Villager.find_by_token_for(:login, @token)

      if villager
        session[:villager_id] = villager.id
        redirect_to(session.delete(:return_to) || edit_profile_path, notice: "Signed in.")
      else
        redirect_to new_session_path, alert: "Invalid or expired login link."
      end
    end
    # GET just renders the confirmation form
  end

  def destroy
    session.delete(:villager_id)
    redirect_to root_path, notice: "Signed out."
  end
end
