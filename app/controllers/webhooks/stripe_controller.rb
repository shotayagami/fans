module Webhooks
  class StripeController < ActionController::API
    def create
      event = Stripe::Webhook.construct_event(
        request.raw_post, request.headers["Stripe-Signature"], ENV.fetch("STRIPE_WEBHOOK_SECRET")
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head :bad_request
    else
      return head :ok unless StripeEvent::HANDLED_TYPES.include?(event.type)

      # Stripe retries deliveries; the unique event id makes a redelivery a no-op.
      record = StripeEvent.create_or_find_by!(stripe_event_id: event.id) do |e|
        e.event_type = event.type
        e.payload = event.to_hash
      end
      # Enqueue until the event is processed, not only when it is first stored: if the
      # enqueue failed (500), Stripe's retry must be able to recover the stored event.
      # StripeEvent#process! is idempotent, so an extra job is harmless.
      StripeEventJob.perform_later(record) unless record.processed_at
      head :ok
    end
  end
end
