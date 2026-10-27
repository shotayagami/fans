class User < ApplicationRecord
  # ponytail: no :recoverable because the demo has no mail delivery; add it with an SMTP relay.
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  enum :role, { fan: 0, creator: 1 }, validate: true

  has_many :plans, foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy
  has_many :subscriptions, foreign_key: :fan_id, inverse_of: :fan, dependent: :destroy

  validates :display_name, presence: true, length: { maximum: 50 }

  def stripe_customer_id!
    stripe_customer_id || Stripe::Customer.create(email: email, name: display_name).id.tap do |id|
      update!(stripe_customer_id: id)
    end
  end

  def connect_onboarding_url(refresh_url:, return_url:)
    update!(stripe_account_id: create_connect_account.id) unless stripe_account_id
    Stripe::AccountLink.create(account: stripe_account_id, refresh_url: refresh_url,
                               return_url: return_url, type: "account_onboarding").url
  end

  # ponytail: synced when the creator returns from onboarding; add a Connect webhook for account.updated if accounts change later.
  def refresh_connect_status!
    return unless stripe_account_id

    update!(charges_enabled: Stripe::Account.retrieve(stripe_account_id).charges_enabled)
  end

  def subscribed_to?(plan)
    subscriptions.active.exists?(plan: plan)
  end

  private

  def create_connect_account
    Stripe::Account.create(
      country: "JP",
      email: email,
      controller: {
        stripe_dashboard: { type: "express" },
        fees: { payer: "application" },
        losses: { payments: "application" }
      },
      capabilities: { transfers: { requested: true } }
    )
  end
end
