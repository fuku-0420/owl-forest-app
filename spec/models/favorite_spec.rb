require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe 'バリデーション' do
    it 'userとadviceがあれば有効であること' do
      favorite = build(:favorite)
      expect(favorite).to be_valid
    end

    it 'userがなければ無効であること' do
      favorite = build(:favorite, user: nil)
      expect(favorite).not_to be_valid
      expect(favorite.errors[:user]).to be_present
    end

    it 'adviceがなければ無効であること' do
      favorite = build(:favorite, advice: nil)
      expect(favorite).not_to be_valid
      expect(favorite.errors[:advice]).to be_present
    end

    it '同じuserが同じadviceを重複お気に入りできないこと' do
      user = create(:user)
      advice = create(:advice)
      create(:favorite, user: user, advice: advice)

      duplicate_favorite = build(:favorite, user: user, advice: advice)
      expect(duplicate_favorite).not_to be_valid
      expect(duplicate_favorite.errors[:user_id]).to be_present
    end
  end

  describe 'アソシエーション' do
    it 'userに紐づくこと' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'adviceに紐づくこと' do
      association = described_class.reflect_on_association(:advice)
      expect(association.macro).to eq :belongs_to
    end
  end
end
