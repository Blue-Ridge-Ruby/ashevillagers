class ProfileQuestion < ApplicationRecord
  has_many :profile_answers, dependent: :destroy

  validates :question, presence: true

  scope :active, -> { where(active: true).order(:position) }
end
