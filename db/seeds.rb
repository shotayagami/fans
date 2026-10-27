# Demo data for screens. The seeded creator has no real Stripe account, so checkout
# only works for creators who complete Connect onboarding in test mode.
creator = User.find_or_create_by!(email: "creator@example.com") do |u|
  u.password = "password123"
  u.display_name = "しおり工房"
  u.role = :creator
  u.charges_enabled = true
end
User.find_or_create_by!(email: "fan@example.com") do |u|
  u.password = "password123"
  u.display_name = "ファンA"
end
User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password123"
  u.display_name = "管理者"
  u.admin = true
end

light = creator.plans.find_or_create_by!(name: "ライト") { |p| p.price = 300; p.description = "制作の進み具合を週に一度お届けします。" }
full = creator.plans.find_or_create_by!(name: "まるごと") { |p| p.price = 1_000; p.description = "ラフと完成データ、メイキング記事を読めます。" }

light.posts.find_or_create_by!(title: "今週の進み具合") { |p| p.body = "表紙のラフが固まりました。"; p.published_at = 2.days.ago }
full.posts.find_or_create_by!(title: "表紙ができるまで") { |p| p.body = "線画から色を置くまでの手順を順に書きます。"; p.published_at = 1.day.ago }
