class CreateLedgerEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_entries do |t|
      t.references :subscription, null: false, foreign_key: true
      t.string :stripe_invoice_id, null: false
      t.integer :gross_amount, null: false
      t.integer :platform_fee, null: false
      t.integer :creator_amount, null: false
      t.datetime :paid_at, null: false

      t.timestamps
    end
    add_index :ledger_entries, :stripe_invoice_id, unique: true
  end
end
