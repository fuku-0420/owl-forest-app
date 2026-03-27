FactoryBot.define do
  factory :advice do
    association :category
    title { "サンプルタイトル" }
    body { "サンプル本文です" }
    views_count { 0 }
  end
end
