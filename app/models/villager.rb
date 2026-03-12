class Villager < ApplicationRecord
  generates_token_for :login, expires_in: 30.days

  validates :first_name, presence: true, on: :interactive
  validates :last_name, presence: true, on: :interactive
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
