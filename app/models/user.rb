class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :advice_suggestions, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_advices, through: :favorites, source: :advice

  # 👤 プロフィール
  has_one :profile, dependent: :destroy
  after_create_commit :ensure_profile!

  def admin?
    admin == true
  end

  def display_name_or_email
    profile&.display_name.presence || email
  end

  private

  # User作成を失敗させないため「作れなかったらログだけ」にする
  def ensure_profile!
    create_profile! if profile.nil?
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[ensure_profile!] user_id=#{id} profile create failed: #{e.message}")
  end
end
