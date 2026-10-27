require "rails_helper"

RSpec.describe "加入中のプラン" do
  let(:fan) { create(:user) }
  let(:subscription) { create(:subscription, fan: fan) }

  before { sign_in fan }

  it "解約すると期間の終わりでの解約を Stripe に依頼し、画面にも反映する" do
    allow(Stripe::Subscription).to receive(:update)

    delete subscription_path(subscription)

    expect(Stripe::Subscription).to have_received(:update).with(subscription.stripe_subscription_id, cancel_at_period_end: true)
    follow_redirect!
    expect(response.body).to include("解約予定")
    expect(response.body).not_to include("期間の終わりで解約します。よろしいですか")
  end

  it "他人の加入は解約できない" do
    others = create(:subscription)
    expect(Stripe::Subscription).not_to receive(:update)

    delete subscription_path(others)

    expect(response).to have_http_status(:not_found)
  end
end
