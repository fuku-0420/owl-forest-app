require 'rails_helper'

RSpec.describe Advice, type: :model do
  describe 'バリデーション' do
    it 'title、body、category があれば有効であること' do
      advice = build(:advice)
      expect(advice).to be_valid
    end

    it 'title がなければ無効であること' do
      advice = build(:advice, title: nil)
      expect(advice).not_to be_valid
      expect(advice.errors[:title]).to include('入力してください')
    end

    it 'body がなければ無効であること' do
      advice = build(:advice, body: nil)
      expect(advice).not_to be_valid
      expect(advice.errors[:body]).to include('入力してください')
    end

    it 'category がなければ無効であること' do
      advice = build(:advice, category: nil)
      expect(advice).not_to be_valid
      expect(advice.errors[:category]).to be_present
    end
  end

  describe 'アソシエーション' do
    it 'category に紐づくこと' do
      association = described_class.reflect_on_association(:category)
      expect(association.macro).to eq :belongs_to
    end

    it 'advice_suggestion に紐づくこと（optional）' do
      association = described_class.reflect_on_association(:advice_suggestion)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:optional]).to eq true
    end

    it 'favorites を複数持つこと' do
      association = described_class.reflect_on_association(:favorites)
      expect(association.macro).to eq :has_many
    end
  end

  describe '.popular_by_views' do
    it 'views_count の降順、同じなら created_at の降順で並ぶこと' do
      older_high_views = create(:advice, views_count: 10, created_at: 2.days.ago)
      newer_high_views = create(:advice, views_count: 10, created_at: 1.day.ago)
      low_views = create(:advice, views_count: 5, created_at: Time.current)

      result = Advice.where(id: [ older_high_views.id, newer_high_views.id, low_views.id ]).popular_by_views

      expect(result.pluck(:id)).to eq([ newer_high_views.id, older_high_views.id, low_views.id ])
    end
  end
end
