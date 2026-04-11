class ProfileAnswer < ApplicationRecord
  belongs_to :profile
  belongs_to :profile_question
end
