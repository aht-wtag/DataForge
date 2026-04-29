class SeedDilocDefaultData < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      INSERT INTO std_train_timetableperiods (id, date_period_start, date_period_end, deleted, created_at, updated_at)
      VALUES (gen_random_uuid(), '1970-01-01', '2099-12-31', false, NOW(), NOW());
    SQL

    execute <<~SQL
      INSERT INTO diloc_statuses (id, state, last_synced, created_at, updated_at)
      VALUES (1, 0, NULL, NOW(), NOW());
    SQL
  end

  def down
    execute "DELETE FROM diloc_statuses WHERE id = 1"
    execute "DELETE FROM std_train_timetableperiods WHERE date_period_start = '1970-01-01'"
  end
end
