class CreateExecutionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :execution_logs do |t|
      t.references :adapter, null: false, foreign_key: true
      t.references :endpoint, foreign_key: true
      t.references :job_schedule, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :records_extracted, default: 0
      t.integer :records_transformed, default: 0
      t.integer :records_loaded, default: 0
      t.text :error_message
      t.text :error_trace
      t.jsonb :raw_payload
      t.jsonb :transformed_payload
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :duration_ms

      t.timestamps
    end
  end
end
