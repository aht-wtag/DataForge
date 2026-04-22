class CreateTransformationRules < ActiveRecord::Migration[7.1]
  def change
    create_table :transformation_rules do |t|
      t.references :endpoint, null: false, foreign_key: true
      t.string :source_path, null: false
      t.string :target_field, null: false
      t.integer :target_type, default: 0, null: false
      t.string :default_value
      t.text :transformation_expression
      t.integer :position, default: 0, null: false
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end
  end
end
