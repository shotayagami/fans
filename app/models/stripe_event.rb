class StripeEvent < ApplicationRecord
  HANDLED_TYPES = %w[
    customer.subscription.created
    customer.subscription.updated
    customer.subscription.deleted
    invoice.paid
  ].freeze

  # Uniqueness is left to the DB index so create_or_find_by! can rely on it.
  validates :stripe_event_id, presence: true
  validates :event_type, inclusion: { in: HANDLED_TYPES }

  def process!
    return if processed_at

    object = Stripe::Event.construct_from(payload).data.object
    case event_type
    when /\Acustomer\.subscription\./
      Subscription.sync_from_stripe!(Stripe::Subscription.retrieve(object.id))
    when "invoice.paid"
      LedgerEntry.record_invoice!(object)
    end
    update!(processed_at: Time.current)
  end
end
