module Studio
  # One account can both support creators and be a creator, so "becoming a creator"
  # is an opt-in on an existing account, not a choice made at sign-up.
  class EnrollmentsController < ApplicationController
    before_action :authenticate_user!
    before_action -> { redirect_to studio_root_path if current_user.creator? }

    def new
    end

    def create
      current_user.creator!
      redirect_to studio_connect_path, notice: "クリエイターになりました。まず受取口座を登録してください"
    end
  end
end
