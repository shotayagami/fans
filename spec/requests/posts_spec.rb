require "rails_helper"

RSpec.describe "投稿の閲覧" do
  let(:post_record) { create(:post, body: "ここから先は支援者だけ") }

  it "未加入なら本文を出さず、支援の導線を出す" do
    sign_in create(:user)
    get post_path(post_record)

    expect(response.body).not_to include("ここから先は支援者だけ")
    expect(response.body).to include("支援者だけが読めます")
  end

  it "加入中なら本文を出す" do
    fan = create(:user)
    create(:subscription, fan: fan, plan: post_record.plan)
    sign_in fan
    get post_path(post_record)

    expect(response.body).to include("ここから先は支援者だけ")
  end

  it "公開前の投稿は見つからない扱いにする" do
    draft = create(:post, published_at: nil)
    get post_path(draft)

    expect(response).to have_http_status(:not_found)
  end
end
