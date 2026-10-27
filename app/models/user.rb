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

  # Connected accounts use Accounts v2: Stripe rejects v1 account creation for new Connect integrations.
  def connect_onboarding_url(refresh_url:, return_url:)
    update!(stripe_account_id: create_connect_account.id) unless stripe_account_id
    stripe_v2.account_links.create(
      account: stripe_account_id,
      use_case: {
        type: "account_onboarding",
        account_onboarding: { refresh_url: refresh_url, return_url: return_url }
      }
    ).url
  end

  # ponytail: synced when the creator returns from onboarding; add a Connect webhook for account updates if accounts change later.
  # The flag means "can receive destination-charge transfers", the only capability this app uses.
  def refresh_connect_status!
    return unless stripe_account_id

    account = stripe_v2.accounts.retrieve(stripe_account_id, include: [ "configuration.recipient" ])
    status = account.configuration&.recipient&.capabilities&.stripe_balance&.stripe_transfers&.status
    update!(charges_enabled: status == "active")
  end

  def subscribed_to?(plan)
    subscriptions.active.exists?(plan: plan)
  end

  private

  def create_connect_account
    stripe_v2.accounts.create(
      contact_email: email,
      display_name: display_name,
      dashboard: "express",
      identity: { country: "jp" },
      defaults: {
        currency: "jpy",
        responsibilities: { fees_collector: "application", losses_collector: "application" }
      },
      configuration: { recipient: { capabilities: { stripe_balance: { stripe_transfers: { requested: true } } } } }
    )
  end

  def stripe_v2
    Stripe::StripeClient.new(Stripe.api_key).v2.core
  end
end
