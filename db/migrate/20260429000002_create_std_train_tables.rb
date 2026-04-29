class CreateStdTrainTables < ActiveRecord::Migration[7.1]
  def change
    create_table :std_train_timetableperiods, id: :uuid do |t|
      t.date :date_period_start, null: false
      t.date :date_period_end, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :std_train_operationperiods, id: :uuid do |t|
      t.string :code, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :std_train_operationperiods, :code, unique: true,
              name: 'idx_std_train_operationperiods_on_code'

    create_table :std_train_operationperiods_days, id: :uuid do |t|
      t.references :std_train_operationperiod, type: :uuid, null: false, foreign_key: true
      t.date :date
      t.timestamps
    end

    add_index :std_train_operationperiods_days,
              [:std_train_operationperiod_id, :date],
              unique: true,
              name: 'idx_std_train_opperiods_days_on_period_id_and_date'

    create_table :std_train_trains, id: :uuid do |t|
      t.string :train_nr, null: false
      t.references :std_train_operationperiod, type: :uuid, null: false, foreign_key: true
      t.string :break_series
      t.references :std_train_timetableperiod, type: :uuid, null: false, foreign_key: true
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :std_train_trains, [:train_nr, :std_train_operationperiod_id],
              unique: true,
              name: 'idx_std_train_trains_on_train_nr_and_op_period_id'

    create_table :std_train_locations, id: :uuid do |t|
      t.string :abbreviation, null: false
      t.string :name, null: false
      t.string :provider, null: false, default: 'diloc'
      t.string :provider_id, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :std_train_locations, :provider_id, unique: true,
              name: 'idx_std_train_locations_on_provider_id'

    create_table :std_train_timetables, id: :uuid do |t|
      t.references :std_train_train, type: :uuid, null: false, foreign_key: true
      t.references :std_train_location, type: :uuid, null: false, foreign_key: true
      t.references :std_train_timetableperiod, type: :uuid, null: false, foreign_key: true
      t.string :time_arrival
      t.string :time_departure
      t.integer :offset_departure, null: false, default: 0
      t.string :type_stop
      t.integer :sort, null: false, default: 0
      t.string :provider_id, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :std_train_timetables,
              [:std_train_train_id, :std_train_location_id, :std_train_timetableperiod_id, :provider_id],
              unique: true,
              name: 'idx_std_train_timetables_unique'
  end
end
