module Studio
  class PlansController < BaseController
    before_action :set_plan, only: %i[edit update]

    def index
      @plans = current_user.plans.order(:price)
    end

    def new
      @plan = current_user.plans.build
    end

    def create
      @plan = current_user.plans.build(plan_params)
      if @plan.save
        redirect_to studio_plans_path, notice: "プランを作成しました"
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @plan.update(plan_params)
        redirect_to studio_plans_path, notice: "プランを更新しました"
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_plan
      @plan = current_user.plans.find(params[:id])
    end

    def plan_params
      params.expect(plan: %i[name description price])
    end
  end
end
