class CreateSchemaVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :schema_versions do |t|
      t.string :version, null: false
      t.string :name, null: false
      t.integer :success, default: 0, null: false
      t.text :error_message
      t.datetime :ran_at

      t.timestamps
    end

    add_index :schema_versions, :version, unique: true
  end
end
