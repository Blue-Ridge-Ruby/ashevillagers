class Steward < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :first_name, presence: true
  validates :last_name, presence: true

  generates_token_for :password_reset, expires_in: 1.hour do
    password_salt&.last(10)
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
