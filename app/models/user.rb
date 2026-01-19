class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :advice_suggestions, dependent: :destroy

  def admin?
    admin == true
  end
end
