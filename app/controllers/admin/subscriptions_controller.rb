module Admin
  class SubscriptionsController < ApplicationController
    before_action :authenticate_user!
    before_action -> { raise ActiveRecord::RecordNotFound unless current_user.admin? }

    def index
      @subscriptions = Subscription.includes(:fan, plan: :creator).order(created_at: :desc)
    end
  end
end
