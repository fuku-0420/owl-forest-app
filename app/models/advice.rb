class Advice < ApplicationRecord
  belongs_to :category

  validates :title, presence: true
  validates :body, presence: true
  has_many :favorites, dependent: :destroy
end
