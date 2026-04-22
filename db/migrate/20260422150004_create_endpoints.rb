class CreateEndpoints < ActiveRecord::Migration[7.1]
  def change
    create_table :endpoints do |t|
      t.references :adapter, null: false, foreign_key: true
      t.integer :http_method, default: 0, null: false
      t.string :path, null: false
      t.string :name, null: false
      t.text :description
      t.jsonb :headers, default: {}
      t.jsonb :payload_template, default: {}
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end
  end
end
