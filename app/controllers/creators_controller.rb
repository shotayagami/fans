class CreatorsController < ApplicationController
  def index
    @creators = User.creator.where(charges_enabled: true).order(:display_name)
  end

  def show
    @creator = User.creator.find(params[:id])
    @plans = @creator.plans.order(:price)
    @posts = Post.published.recent.where(plan: @plans).includes(:plan)
  end
end
