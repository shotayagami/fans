require "rails_helper"

RSpec.describe "Stripe webhook" do
  let(:payload) { stripe_event_payload(type: "invoice.paid", object: stripe_invoice).to_json }

  it "署名が合わなければ 400 を返し、何も保存しない" do
    expect {
      post "/webhooks/stripe", params: payload, headers: signed_stripe_headers(payload, secret: "whsec_wrong")
    }.not_to change(StripeEvent, :count)
    expect(response).to have_http_status(:bad_request)
  end

  it "署名が合えばイベントを保存してジョブに回す" do
    expect {
      post "/webhooks/stripe", params: payload, headers: signed_stripe_headers(payload)
    }.to change(StripeEvent, :count).by(1).and have_enqueued_job(StripeEventJob)
    expect(response).to have_http_status(:ok)
  end

  it "同じイベントが再送されても二度は処理しない" do
    post "/webhooks/stripe", params: payload, headers: signed_stripe_headers(payload)

    expect {
      post "/webhooks/stripe", params: payload, headers: signed_stripe_headers(payload)
    }.not_to have_enqueued_job(StripeEventJob)
    expect(response).to have_http_status(:ok)
    expect(StripeEvent.count).to eq 1
  end

  it "扱わない種類のイベントは保存せずに 200 を返す" do
    other = stripe_event_payload(type: "customer.created", object: { id: "cus_1", object: "customer" }).to_json
    expect {
      post "/webhooks/stripe", params: other, headers: signed_stripe_headers(other)
    }.not_to change(StripeEvent, :count)
    expect(response).to have_http_status(:ok)
  end

  it "受信から台帳への記録まで通る" do
    fan = create(:user)
    plan = create(:plan, price: 500)
    allow(Stripe::Subscription).to receive(:retrieve).with("sub_123").and_return(stripe_subscription(fan: fan, plan: plan))

    perform_enqueued_jobs do
      post "/webhooks/stripe", params: payload, headers: signed_stripe_headers(payload)
      post "/webhooks/stripe", params: payload, headers: signed_stripe_headers(payload)
    end

    expect(LedgerEntry.sole).to have_attributes(gross_amount: 500, platform_fee: 50, creator_amount: 450)
    expect(fan.subscribed_to?(plan)).to be true
  end
end
