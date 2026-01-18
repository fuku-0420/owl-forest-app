class Category < ApplicationRecord
  has_many :advices, dependent: :destroy
end

