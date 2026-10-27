require "rails_helper"

RSpec.describe "支援の開始" do
  let(:creator) { create(:creator, stripe_account_id: "acct_creator") }
  let(:plan) { create(:plan, creator: creator, stripe_price_id: "price_1") }
  let(:fan) { create(:user, stripe_customer_id: "cus_1") }

  before { sign_in fan }

  it "クリエイターへの送金と手数料を付けて Checkout に送る" do
    allow(Stripe::Checkout::Session).to receive(:create).and_return(double(url: "https://checkout.stripe.com/c/pay/cs_test"))

    post plan_checkout_path(plan)

    expect(response).to redirect_to("https://checkout.stripe.com/c/pay/cs_test")
    expect(Stripe::Checkout::Session).to have_received(:create).with(hash_including(
      mode: "subscription",
      customer: "cus_1",
      line_items: [ { price: "price_1", quantity: 1 } ],
      subscription_data: hash_including(
        application_fee_percent: 10,
        transfer_data: { destination: "acct_creator" },
        metadata: { fan_id: fan.id, plan_id: plan.id }
      )
    ))
  end

  it "クリエイターも、ほかのクリエイターのプランを応援できる" do
    supporter = create(:creator, stripe_customer_id: "cus_creator")
    sign_in supporter
    allow(Stripe::Checkout::Session).to receive(:create).and_return(double(url: "https://checkout.stripe.com/c/pay/cs_test"))

    post plan_checkout_path(plan)

    expect(response).to redirect_to("https://checkout.stripe.com/c/pay/cs_test")
  end

  it "自分のプランには加入できない" do
    sign_in creator
    expect(Stripe::Checkout::Session).not_to receive(:create)

    post plan_checkout_path(plan)

    expect(response).to redirect_to(creator_path(creator))
  end

  it "受取口座が未登録のクリエイターには支援できない" do
    creator.update!(charges_enabled: false)
    expect(Stripe::Checkout::Session).not_to receive(:create)

    post plan_checkout_path(plan)

    expect(response).to redirect_to(creator_path(creator))
  end

  it "加入中のプランには二重に加入できない" do
    create(:subscription, fan: fan, plan: plan)
    expect(Stripe::Checkout::Session).not_to receive(:create)

    post plan_checkout_path(plan)

    expect(response).to redirect_to(creator_path(creator))
  end
end
