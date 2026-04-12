class StewardMailer < ApplicationMailer
  def password_reset(steward)
    @steward = steward
    @token = steward.generate_token_for(:password_reset)

    mail to: steward.email, from:, subject: "Reset your password"
  end
end
