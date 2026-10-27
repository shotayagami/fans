FactoryBot.define do
  factory :post do
    plan
    title { "限定の投稿" }
    body { "支援者だけが読める本文" }
    published_at { 1.hour.ago }
  end
end
