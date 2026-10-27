module Studio
  class ConnectsController < BaseController
    def show
      current_user.refresh_connect_status! if params[:returned]
    end

    def create
      url = current_user.connect_onboarding_url(
        refresh_url: studio_connect_url,
        return_url: studio_connect_url(returned: 1)
      )
      redirect_to url, allow_other_host: true, status: :see_other
    end
  end
end
