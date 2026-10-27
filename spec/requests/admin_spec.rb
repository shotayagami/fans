require "rails_helper"

RSpec.describe "管理画面" do
  it "管理者は加入状況を一覧できる" do
    create_list(:subscription, 2)
    sign_in create(:user, admin: true)
    get admin_subscriptions_path

    expect(response).to have_http_status(:ok)
  end

  it "管理者以外には存在を見せない" do
    sign_in create(:user)
    get admin_subscriptions_path

    expect(response).to have_http_status(:not_found)
  end
end
