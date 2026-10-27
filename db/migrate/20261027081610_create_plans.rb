class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.integer :price, null: false
      t.string :stripe_price_id

      t.timestamps
    end
    add_index :plans, :stripe_price_id, unique: true
  end
end
