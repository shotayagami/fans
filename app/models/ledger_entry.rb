class LedgerEntry < ApplicationRecord
  PLATFORM_FEE_PERCENT = 10

  belongs_to :subscription
  has_one :plan, through: :subscription

  # Uniqueness is left to the DB index so create_or_find_by! can rely on it.
  validates :stripe_invoice_id, presence: true
  validates :gross_amount, :platform_fee, :creator_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :amounts_balance

  def self.record_invoice!(invoice)
    stripe_subscription_id = invoice.parent&.subscription_details&.subscription
    return unless stripe_subscription_id

    subscription = Subscription.sync_from_stripe!(Stripe::Subscription.retrieve(stripe_subscription_id))
    # ponytail: fee is recomputed from the percent, not read from the Stripe application fee; reconcile against balance transactions if amounts ever diverge.
    fee = invoice.amount_paid * PLATFORM_FEE_PERCENT / 100
    create_or_find_by!(stripe_invoice_id: invoice.id) do |entry|
      entry.subscription = subscription
      entry.gross_amount = invoice.amount_paid
      entry.platform_fee = fee
      entry.creator_amount = invoice.amount_paid - fee
      entry.paid_at = Time.zone.at(invoice.status_transitions.paid_at)
    end
  end

  private

  def amounts_balance
    return if [ gross_amount, platform_fee, creator_amount ].any?(&:nil?)

    errors.add(:base, "金額の内訳が合いません") unless platform_fee + creator_amount == gross_amount
  end
end
