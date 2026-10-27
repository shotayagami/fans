module StripeHelpers
  def stripe_subscription(id: "sub_123", status: "active", period_end: 1.month.from_now, fan:, plan:)
    Stripe::Subscription.construct_from(
      id: id,
      object: "subscription",
      status: status,
      metadata: { fan_id: fan.id.to_s, plan_id: plan.id.to_s },
      items: { object: "list", data: [ { id: "si_1", object: "subscription_item", current_period_end: period_end.to_i } ] }
    )
  end

  def stripe_invoice(id: "in_123", subscription_id: "sub_123", amount_paid: 500, paid_at: Time.current)
    {
      id: id,
      object: "invoice",
      amount_paid: amount_paid,
      parent: { type: "subscription_details", subscription_details: { subscription: subscription_id } },
      status_transitions: { paid_at: paid_at.to_i }
    }
  end

  def stripe_event_payload(id: "evt_123", type:, object:)
    { id: id, object: "event", type: type, data: { object: object } }
  end

  def signed_stripe_headers(payload, secret: ENV.fetch("STRIPE_WEBHOOK_SECRET"))
    timestamp = Time.current
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload, secret)
    { "Stripe-Signature" => Stripe::Webhook::Signature.generate_header(timestamp, signature), "Content-Type" => "application/json" }
  end
end
