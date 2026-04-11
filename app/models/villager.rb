class Villager < ApplicationRecord
  include Configuration::Configurable

  configure_with :tito_account_slug, :tito_event_slug, :tito_api_token, instance_methods: false

  has_one :profile, dependent: :destroy

  before_save :memorialize_tito_config

  generates_token_for :login, expires_in: 30.days

  validates :first_name, presence: true, on: :interactive
  validates :last_name, presence: true, on: :interactive
  validates :email, presence: true, on: :interactive
  validates :email, presence: true, unless: :tito_ticket_slug

  normalizes :first_name, :last_name, :tito_ticket_slug, with: ->(v) { v.presence }
  normalizes :email, with: ->(email) { email.strip.downcase.presence }

  def tito_event_slug = attributes["tito_event_slug"] || self.class.tito_event_slug
  def tito_account_slug = attributes["tito_account_slug"] || self.class.tito_account_slug
  def tito_api_token = self.class.tito_api_token

  def self.tito_client = Tito::Admin::Client.new(token: tito_api_token, account: tito_account_slug, event: tito_event_slug)

  def tito_client = Tito::Admin::Client.new(token: tito_api_token, account: tito_account_slug, event: tito_event_slug)

  def admin_ticket_url = tito_ticket_slug && "https://dashboard.tito.io/#{tito_account_slug}/#{tito_event_slug}/tickets/#{tito_ticket_slug}"

  private

  def memorialize_tito_config
    return unless tito_ticket_slug.present?
    self.tito_account_slug = tito_account_slug
    self.tito_event_slug = tito_event_slug
  end
end
