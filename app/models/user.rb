class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :advice_suggestions, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_advices, through: :favorites, source: :advice

  def admin?
    admin == true
  end
end
