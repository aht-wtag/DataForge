class CreateDilocStatusesAndAdapterRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :diloc_statuses do |t|
      t.integer :state, null: false, default: 0
      t.datetime :last_synced
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE diloc_statuses ADD CONSTRAINT chk_diloc_status_single_row CHECK (id = 1);
        SQL
      end
      dir.down do
        execute <<~SQL
          ALTER TABLE diloc_statuses DROP CONSTRAINT IF EXISTS chk_diloc_status_single_row;
        SQL
      end
    end

    create_table :adapter_runs do |t|
      t.references :adapter, null: false, foreign_key: true
      t.string :name, null: false
      t.string :state, null: false, default: 'new'
      t.integer :progress, null: false, default: 0
      t.integer :timeout
      t.jsonb :result
      t.text :error
      t.text :stack
      t.datetime :ended_at
      t.timestamps
    end

    add_index :adapter_runs, :state
    add_index :adapter_runs, :created_at
  end
end
