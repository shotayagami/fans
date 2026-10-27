require "rails_helper"

RSpec.describe Plan do
  it "月額は 100〜50,000 円の整数に限る" do
    expect(build(:plan, price: 99)).not_to be_valid
    expect(build(:plan, price: 50_001)).not_to be_valid
    expect(build(:plan, price: 100)).to be_valid
  end

  it "金額を変えたら Stripe の価格を作り直す" do
    plan = create(:plan, stripe_price_id: "price_old")
    plan.update!(price: 800)
    expect(plan.stripe_price_id).to be_nil
  end

  it "名前だけの変更では Stripe の価格を保つ" do
    plan = create(:plan, stripe_price_id: "price_old")
    plan.update!(name: "新しい名前")
    expect(plan.stripe_price_id).to eq "price_old"
  end
end
