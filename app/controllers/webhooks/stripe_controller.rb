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
      StripeEventJob.perform_later(record) if record.previously_new_record?
      head :ok
    end
  end
end
