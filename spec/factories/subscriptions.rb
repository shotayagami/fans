FactoryBot.define do
  factory :subscription do
    association :fan, factory: :user
    plan
    sequence(:stripe_subscription_id) { |n| "sub_#{n}" }
    status { "active" }
    current_period_end { 1.month.from_now }
  end
end
