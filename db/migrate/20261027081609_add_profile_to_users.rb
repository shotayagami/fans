class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :display_name, :string, null: false, default: ""
    add_column :users, :admin, :boolean, null: false, default: false
    add_column :users, :stripe_customer_id, :string
    add_index :users, :stripe_customer_id, unique: true
    add_column :users, :stripe_account_id, :string
    add_index :users, :stripe_account_id, unique: true
    add_column :users, :charges_enabled, :boolean, null: false, default: false
  end
end
