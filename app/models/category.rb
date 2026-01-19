class Category < ApplicationRecord
  has_many :advices, dependent: :destroy
  has_many :advice_suggestions, dependent: :destroy
end
