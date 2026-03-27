FactoryBot.define do
  factory :favorite do
    association :user
    association :advice
  end
end
