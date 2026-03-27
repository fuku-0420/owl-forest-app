FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "カテゴリ_#{n}_#{SecureRandom.hex(4)}" }
  end
end
