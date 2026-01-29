class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar

  validates :display_name, length: { maximum: 30 }, allow_blank: true
  validates :bio, length: { maximum: 300 }, allow_blank: true
end
