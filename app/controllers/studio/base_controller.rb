module Studio
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action -> { redirect_to new_studio_enrollment_path unless current_user.creator? }
  end
end
