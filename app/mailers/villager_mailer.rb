class VillagerMailer < ApplicationMailer
  def login_link(villager)
    @villager = villager
    @token = villager.generate_token_for(:login)
    @login_url = callback_session_url(token: @token)

    mail to: villager.email, subject: "Your Ashevillagers login link"
  end
end
