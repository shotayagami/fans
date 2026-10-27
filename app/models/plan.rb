class Plan < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :posts, dependent: :destroy
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 1000 }
  validates :price, numericality: { only_integer: true, in: 100..50_000 }

  # Stripe prices are immutable, so a new one is created on the next checkout.
  before_update { self.stripe_price_id = nil if price_changed? }

  def stripe_price_id!
    stripe_price_id || Stripe::Price.create(
      currency: "jpy",
      unit_amount: price,
      recurring: { interval: "month" },
      product_data: { name: "#{creator.display_name} / #{name}" }
    ).id.tap { |id| update_column(:stripe_price_id, id) }
  end
end
