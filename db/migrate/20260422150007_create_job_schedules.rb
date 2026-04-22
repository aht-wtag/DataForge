class CreateJobSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :job_schedules do |t|
      t.references :adapter, null: false, foreign_key: true
      t.references :endpoint, null: false, foreign_key: true
      t.string :cron_expression, null: false
      t.string :timezone, null: false, default: "UTC"
      t.boolean :enabled, default: true, null: false
      t.datetime :last_run_at
      t.datetime :next_run_at

      t.timestamps
    end
  end
end
