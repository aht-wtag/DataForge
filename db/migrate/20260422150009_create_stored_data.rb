class CreateStoredData < ActiveRecord::Migration[7.1]
  def change
    create_table :stored_data do |t|
      t.references :adapter, null: false, foreign_key: true
      t.references :endpoint, null: false, foreign_key: true
      t.references :execution_log, foreign_key: true
      t.jsonb :data, null: false, default: {}
      t.string :record_hash

      t.timestamps
    end

    add_index :stored_data, :record_hash, unique: true
    add_index :stored_data, :data, using: :gin
  end
end
