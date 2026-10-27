require "rails_helper"

RSpec.describe "クリエイターになる" do
  it "ファンは同じアカウントのままクリエイターになれる" do
    fan = create(:user)
    sign_in fan

    post studio_enrollment_path

    expect(fan.reload).to be_creator
    expect(response).to redirect_to(studio_connect_path)
  end

  it "すでにクリエイターなら、スタジオへ戻す" do
    sign_in create(:creator)

    get new_studio_enrollment_path

    expect(response).to redirect_to(studio_root_path)
  end

  it "ログインしていなければ入れない" do
    get new_studio_enrollment_path

    expect(response).to redirect_to(new_user_session_path)
  end
end
