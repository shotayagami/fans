module Studio
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action -> { redirect_to root_path, alert: "クリエイター専用のページです" unless current_user.creator? }
  end
end
