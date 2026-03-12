class Advice < ApplicationRecord
  belongs_to :category
  belongs_to :advice_suggestion, optional: true

  validates :title, presence: true
  validates :body, presence: true

  has_many :favorites, dependent: :destroy

  scope :popular_by_views, -> { order(views_count: :desc, created_at: :desc) }
end
