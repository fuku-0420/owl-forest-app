require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#admin?' do
    it 'adminがtrueならtrueを返すこと' do
      user = build(:user, admin: true)
      expect(user.admin?).to eq true
    end

    it 'adminがfalseならfalseを返すこと' do
      user = build(:user, admin: false)
      expect(user.admin?).to eq false
    end
  end

  describe '#display_name_or_email' do
    it 'profileのdisplay_nameがあればそれを返すこと' do
      user = create(:user)
      user.profile.update!(display_name: 'フクちゃん')

      expect(user.display_name_or_email).to eq 'フクちゃん'
    end

    it 'profileのdisplay_nameが空ならemailを返すこと' do
      user = create(:user)
      user.profile.update!(display_name: '')

      expect(user.display_name_or_email).to eq user.email
    end

    it 'profileがなくてもemailを返すこと' do
      user = create(:user)
      user.profile.destroy!

      expect(user.display_name_or_email).to eq user.email
    end
  end

  describe 'after_create_commit' do
    it 'ユーザー作成時にprofileも作成されること' do
      user = create(:user)
      expect(user.profile).to be_present
    end
  end
end
