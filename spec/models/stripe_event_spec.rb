require "rails_helper"

RSpec.describe StripeEvent do
  describe "#process!" do
    let(:fan) { create(:user) }
    let(:plan) { create(:plan) }

    it "サブスクリプションのイベントは最新の状態を取り直して反映する" do
      # The payload says active, but the subscription was canceled since; the retrieved state wins.
      payload = stripe_event_payload(type: "customer.subscription.updated", object: { id: "sub_123", object: "subscription", status: "active" })
      event = described_class.create!(stripe_event_id: "evt_1", event_type: payload[:type], payload: payload)
      allow(Stripe::Subscription).to receive(:retrieve).with("sub_123")
        .and_return(stripe_subscription(fan: fan, plan: plan, status: "canceled"))

      event.process!

      expect(Subscription.find_by!(stripe_subscription_id: "sub_123").status).to eq "canceled"
      expect(event.reload.processed_at).to be_present
    end

    it "処理済みのイベントは再処理しない" do
      payload = stripe_event_payload(type: "invoice.paid", object: stripe_invoice)
      event = described_class.create!(stripe_event_id: "evt_1", event_type: payload[:type], payload: payload, processed_at: 1.minute.ago)

      expect(Stripe::Subscription).not_to receive(:retrieve)
      event.process!
    end
  end
end
