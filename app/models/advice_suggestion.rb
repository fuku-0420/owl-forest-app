class AdviceSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :status, { pending: 0, approved: 1, rejected: 2 }, prefix: true

  validates :body, presence: true
end
