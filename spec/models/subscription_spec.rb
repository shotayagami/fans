require "rails_helper"

RSpec.describe Subscription do
  describe ".sync_from_stripe!" do
    let(:fan) { create(:user) }
    let(:plan) { create(:plan) }

    it "metadata から支援者とプランを決めて作る" do
      subscription = described_class.sync_from_stripe!(stripe_subscription(fan: fan, plan: plan))

      expect(subscription).to have_attributes(fan: fan, plan: plan, status: "active", stripe_subscription_id: "sub_123")
      expect(fan.subscribed_to?(plan)).to be true
    end

    it "同じ Stripe の ID なら既存の行を更新する" do
      described_class.sync_from_stripe!(stripe_subscription(fan: fan, plan: plan))

      expect {
        described_class.sync_from_stripe!(stripe_subscription(fan: fan, plan: plan, status: "canceled"))
      }.not_to change(described_class, :count)
      expect(fan.subscribed_to?(plan)).to be false
    end
  end
end
