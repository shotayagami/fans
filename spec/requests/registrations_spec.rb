require "rails_helper"

RSpec.describe "登録" do
  it "フォームから role を送られても、ファンとして登録する" do
    post user_registration_path, params: {
      user: { email: "new@example.com", password: "password123", password_confirmation: "password123",
              display_name: "新しい人", role: "creator" }
    }

    expect(User.find_by!(email: "new@example.com")).to be_fan
  end
end
