require "rails_helper"

RSpec.describe "スタジオ" do
  let(:creator) { create(:creator) }

  it "クリエイターでなければ、クリエイターになる案内へ送る" do
    sign_in create(:user)
    get studio_plans_path

    expect(response).to redirect_to(new_studio_enrollment_path)
  end

  it "プランを作れる" do
    sign_in creator

    expect {
      post studio_plans_path, params: { plan: { name: "ゴールド", price: 1_000, description: "" } }
    }.to change(creator.plans, :count).by(1)
  end

  it "他人のプランに投稿を付けられない" do
    sign_in creator
    others_plan = create(:plan)

    expect {
      post studio_posts_path, params: { post: { plan_id: others_plan.id, title: "t", body: "b" } }
    }.not_to change(Post, :count)
    expect(response).to have_http_status(:not_found)
  end

  it "他人の投稿は編集できない" do
    sign_in creator
    get edit_studio_post_path(create(:post))

    expect(response).to have_http_status(:not_found)
  end
end
