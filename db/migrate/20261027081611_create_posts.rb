class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :plan, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :posts, [ :plan_id, :published_at ]
  end
end
