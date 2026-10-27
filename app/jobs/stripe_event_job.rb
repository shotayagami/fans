class StripeEventJob < ApplicationJob
  queue_as :default
  retry_on Stripe::APIConnectionError, Stripe::RateLimitError, wait: :polynomially_longer
  # Two events for the same new subscription can race on the unique index; the retry finds the row.
  retry_on ActiveRecord::RecordNotUnique, wait: 1.second, attempts: 3

  def perform(stripe_event)
    stripe_event.process!
  end
end
