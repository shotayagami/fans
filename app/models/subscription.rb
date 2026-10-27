class Subscription < ApplicationRecord
  ACCESS_STATUSES = %w[active trialing].freeze

  belongs_to :fan, class_name: "User"
  belongs_to :plan
  has_many :ledger_entries, dependent: :restrict_with_error

  validates :stripe_subscription_id, presence: true, uniqueness: true
  validates :status, presence: true

  scope :active, -> { where(status: ACCESS_STATUSES).where(current_period_end: Time.current..) }

  # Always called with a freshly retrieved object, so webhook delivery order does not matter.
  def self.sync_from_stripe!(stripe_subscription)
    find_or_initialize_by(stripe_subscription_id: stripe_subscription.id).tap do |subscription|
      subscription.fan_id ||= stripe_subscription.metadata["fan_id"]
      subscription.plan_id ||= stripe_subscription.metadata["plan_id"]
      subscription.status = stripe_subscription.status
      subscription.cancel_at_period_end = stripe_subscription.cancel_at_period_end ? true : false
      subscription.current_period_end = Time.zone.at(stripe_subscription.items.data.first.current_period_end)
      subscription.save!
    end
  end

  def cancel_at_period_end!
    Stripe::Subscription.update(stripe_subscription_id, cancel_at_period_end: true)
    # Reflect it now; the customer.subscription.updated webhook then confirms the same state.
    update!(cancel_at_period_end: true)
  end

  def canceling?
    cancel_at_period_end? && status.in?(ACCESS_STATUSES)
  end
end
