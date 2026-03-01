class AdviceSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :category

  # 🔹 公開されたAdviceとの関連（1投稿につき1公開）
  has_one :advice, dependent: :nullify

  enum :status, { pending: 0, approved: 1, rejected: 2, deleted: 3 }, prefix: true

  before_validation :set_default_category, on: :create

  validates :title, presence: true, length: { maximum: 80 }
  validates :body, presence: true

  private

  def set_default_category
    return if category_id.present?

    default_category = Category.find_by(name: "みんなのお悩み解決")
    self.category = default_category if default_category.present?
  end
end
