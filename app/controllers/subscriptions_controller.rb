class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subscriptions = current_user.subscriptions.includes(plan: :creator).order(created_at: :desc)
  end

  def destroy
    current_user.subscriptions.active.find(params[:id]).cancel_at_period_end!
    redirect_to subscriptions_path, notice: "解約を受け付けました。現在の期間の終わりまでは閲覧できます", status: :see_other
  end
end
