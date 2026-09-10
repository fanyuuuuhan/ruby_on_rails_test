FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    status { [ "pending", "in_progress", "completed" ].sample }
  end
end