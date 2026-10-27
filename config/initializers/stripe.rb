Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# This app is a public demo; refuse to boot with a live key.
if Stripe.api_key.present? && !Stripe.api_key.start_with?("sk_test_", "rk_test_")
  raise "STRIPE_SECRET_KEY must be a test mode key"
end
