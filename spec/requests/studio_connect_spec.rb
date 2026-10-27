require "rails_helper"

RSpec.describe "受取口座の登録画面" do
  let(:creator) { create(:creator, charges_enabled: false, stripe_account_id: "acct_1") }

  before { sign_in creator }

  it "Stripe 側で有効になっていれば、戻った直後に登録済みと表示する" do
    allow_any_instance_of(User).to receive(:refresh_connect_status!) { |user| user.update!(charges_enabled: true) }

    get studio_connect_path(returned: 1)

    expect(response.body).to include("登録済みです")
  end

  it "Stripe 側がまだ有効でなければ、確認中の案内を出し、登録のやり直しを促さない" do
    allow_any_instance_of(User).to receive(:refresh_connect_status!)

    get studio_connect_path(returned: 1)

    expect(response.body).to include("確認が終わるまで")
    expect(response.body).not_to include("Stripe で受取口座を登録します")
  end
end
