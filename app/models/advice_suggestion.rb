class AdviceSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :status, { pending: 0, approved: 1, rejected: 2 }, prefix: true

  before_validation :set_default_category, on: :create

  validates :title, presence: true, length: { maximum: 80 }
  validates :body, presence: true

  private

  def set_default_category
    return if category_id.present?

    self.category = Category.find_by(name: "みんなのお悩み解決")
  end
end