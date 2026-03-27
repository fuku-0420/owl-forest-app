FactoryBot.define do
  factory :profile do
    association :user
    display_name { "フクちゃん" }
    bio { "よろしくお願いします" }
  end
end
