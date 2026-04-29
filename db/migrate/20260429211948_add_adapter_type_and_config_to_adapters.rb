class AddAdapterTypeAndConfigToAdapters < ActiveRecord::Migration[7.1]
  def change
    add_column :adapters, :adapter_type, :integer, null: false, default: 0
    add_column :adapters, :config, :jsonb, null: false, default: {}

    add_index :adapters, :adapter_type
  end
end
