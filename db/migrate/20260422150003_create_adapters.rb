class CreateAdapters < ActiveRecord::Migration[7.1]
  def change
    create_table :adapters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :base_url, null: false
      t.text :description
      t.integer :rate_limit
      t.integer :timeout
      t.integer :status, default: 0, null: false
      t.datetime :archived_at

      t.timestamps
    end

    add_index :adapters, [:user_id, :archived_at]
  end
end
