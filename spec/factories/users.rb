FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    sequence(:display_name) { |n| "ユーザー#{n}" }
    role { :fan }

    factory :creator do
      role { :creator }
      sequence(:stripe_account_id) { |n| "acct_#{n}" }
      charges_enabled { true }
    end
  end
end
