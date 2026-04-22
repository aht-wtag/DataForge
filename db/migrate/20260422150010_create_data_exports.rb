class CreateDataExports < ActiveRecord::Migration[7.1]
  def change
    create_table :data_exports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :adapter, null: false, foreign_key: true
      t.integer :export_format, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.jsonb :filters, default: {}
      t.integer :record_count, default: 0
      t.bigint :file_size_bytes, default: 0
      t.text :error_message

      t.timestamps
    end
  end
end
