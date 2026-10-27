class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :fan, null: false, foreign_key: { to_table: :users }
      t.references :plan, null: false, foreign_key: true
      t.string :stripe_subscription_id, null: false
      t.string :status, null: false
      t.datetime :current_period_end

      t.timestamps
    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
