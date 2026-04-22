class CreateCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :credentials do |t|
      t.references :adapter, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :credential_type, default: 0, null: false
      t.string :auth_header_name
      t.text :encrypted_value
      t.text :encrypted_value_iv

      t.timestamps
    end
  end
end
