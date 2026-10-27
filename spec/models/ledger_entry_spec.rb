require "rails_helper"

RSpec.describe LedgerEntry do
  describe ".record_invoice!" do
    let(:fan) { create(:user) }
    let(:plan) { create(:plan, price: 1_000) }
    let(:invoice) { Stripe::Invoice.construct_from(stripe_invoice(amount_paid: 1_000)) }

    before do
      allow(Stripe::Subscription).to receive(:retrieve).with("sub_123").and_return(stripe_subscription(fan: fan, plan: plan))
    end

    it "支援額を手数料と受取額に分けて記録する" do
      entry = described_class.record_invoice!(invoice)

      expect(entry).to have_attributes(gross_amount: 1_000, platform_fee: 100, creator_amount: 900)
      expect(entry.subscription.plan).to eq plan
    end

    it "端数は手数料側で切り捨て、受取額との合計を支援額に一致させる" do
      entry = described_class.record_invoice!(Stripe::Invoice.construct_from(stripe_invoice(amount_paid: 555)))

      expect(entry).to have_attributes(platform_fee: 55, creator_amount: 500)
    end

    it "同じ請求書を二度記録しない" do
      described_class.record_invoice!(invoice)
      expect { described_class.record_invoice!(invoice) }.not_to change(described_class, :count)
    end

    it "サブスクリプション以外の請求書は無視する" do
      one_off = Stripe::Invoice.construct_from(stripe_invoice.merge(parent: nil))
      expect(described_class.record_invoice!(one_off)).to be_nil
    end
  end
end
