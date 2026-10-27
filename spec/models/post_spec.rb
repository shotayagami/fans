require "rails_helper"

RSpec.describe Post do
  describe "#viewable_by?" do
    let(:plan) { create(:plan) }
    let(:post) { create(:post, plan: plan) }
    let(:fan) { create(:user) }

    it "隠す: ログインしていない" do
      expect(post.viewable_by?(nil)).to be false
    end

    it "隠す: 加入していない" do
      expect(post.viewable_by?(fan)).to be false
    end

    it "見せる: そのプランに加入中" do
      create(:subscription, fan: fan, plan: plan)
      expect(post.viewable_by?(fan)).to be true
    end

    it "隠す: 別のプランにだけ加入している" do
      create(:subscription, fan: fan, plan: create(:plan, creator: plan.creator))
      expect(post.viewable_by?(fan)).to be false
    end

    it "隠す: 解約済み" do
      create(:subscription, fan: fan, plan: plan, status: "canceled")
      expect(post.viewable_by?(fan)).to be false
    end

    it "隠す: 状態が active のままでも期間が切れている (webhook の取りこぼし)" do
      create(:subscription, fan: fan, plan: plan, current_period_end: 1.minute.ago)
      expect(post.viewable_by?(fan)).to be false
    end

    it "隠す: 支払いが遅延している" do
      create(:subscription, fan: fan, plan: plan, status: "past_due")
      expect(post.viewable_by?(fan)).to be false
    end

    it "見せる: 投稿したクリエイター本人" do
      expect(post.viewable_by?(plan.creator)).to be true
    end
  end

  describe "画像の検証" do
    it "画像以外のファイルを拒否する" do
      post = build(:post)
      post.image.attach(io: StringIO.new("text"), filename: "a.txt", content_type: "text/plain")
      expect(post).not_to be_valid
      expect(post.errors[:image]).to be_present
    end
  end
end
