class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :advice_suggestions, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_advices, through: :favorites, source: :advice

  # 👤 プロフィール
  has_one :profile, dependent: :destroy
  after_create :ensure_profile

  def admin?
    admin == true
  end

  def display_name_or_email
    profile&.display_name.presence || email
  end

  private

  def ensure_profile
    create_profile! unless profile
  end
end
