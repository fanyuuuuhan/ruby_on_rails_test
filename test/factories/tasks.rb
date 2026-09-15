FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "#{Faker::Lorem.sentence} #{n}" }
    content { Faker::Lorem.paragraph }
    status { [ "pending", "in_progress", "completed" ].sample }
    due_date { Faker::Date.between(from: Date.today, to: 1.year.from_now) }
  end
end
