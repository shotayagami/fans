class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    plan = Plan.includes(:creator).find(params[:plan_id])
    return redirect_to creator_path(plan.creator), alert: "このプランは支援を受け付けていません" unless plan.creator.charges_enabled?
    return redirect_to creator_path(plan.creator), alert: "自分のプランには加入できません" if plan.creator == current_user
    return redirect_to creator_path(plan.creator), notice: "すでに加入しています" if current_user.subscribed_to?(plan)

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer: current_user.stripe_customer_id!,
      line_items: [ { price: plan.stripe_price_id!, quantity: 1 } ],
      subscription_data: {
        application_fee_percent: LedgerEntry::PLATFORM_FEE_PERCENT,
        transfer_data: { destination: plan.creator.stripe_account_id },
        metadata: { fan_id: current_user.id, plan_id: plan.id }
      },
      success_url: subscriptions_url(checkout: "success"),
      cancel_url: creator_url(plan.creator)
    )
    redirect_to session.url, allow_other_host: true, status: :see_other
  end
end
