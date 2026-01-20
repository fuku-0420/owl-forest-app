class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :advice

  validates :user_id, uniqueness: { scope: :advice_id }
end
