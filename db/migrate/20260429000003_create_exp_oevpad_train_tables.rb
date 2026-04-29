class CreateExpOevpadTrainTables < ActiveRecord::Migration[7.1]
  def change
    create_table :exp_oevpad_train_timetableperiods do |t|
      t.uuid :adapter_id, null: false
      t.date :date_period_start, null: false
      t.date :date_period_end, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :exp_oevpad_train_timetableperiods, :adapter_id, unique: true,
              name: 'idx_exp_oevpad_train_timetableperiods_on_adapter_id'

    create_table :exp_oevpad_train_operationdays do |t|
      t.uuid :adapter_id, null: false
      t.text :code_op_period, null: false
      t.datetime :date, null: false
      t.string :period_key, null: false
      t.uuid :adapter_id_timetable_period, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :exp_oevpad_train_operationdays, :date, unique: true,
              name: 'idx_exp_oevpad_train_operationdays_on_date'

    create_table :exp_oevpad_train_trains do |t|
      t.uuid :adapter_id, null: false
      t.string :train_nr, null: false
      t.string :train_part
      t.text :code_op_period, null: false
      t.datetime :break_series
      t.uuid :adapter_id_timetable_period, null: false
      t.boolean :on_request, null: false, default: false
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :exp_oevpad_train_trains, :adapter_id, unique: true,
              name: 'idx_exp_oevpad_train_trains_on_adapter_id'

    create_table :exp_oevpad_train_trainlocations do |t|
      t.uuid :adapter_id, null: false
      t.uuid :adapter_id_train, null: false
      t.uuid :adapter_id_location, null: false
      t.string :loc_abbreviation, null: false
      t.uuid :adapter_id_timetable_period, null: false
      t.string :time_arrival
      t.integer :offset_arrival, null: false, default: 0
      t.string :time_departure
      t.integer :offset_departure
      t.string :track_info
      t.string :type_stop, null: false
      t.integer :sort, null: false, default: 0
      t.boolean :deleted, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :exp_oevpad_train_trainlocations, :adapter_id, unique: true,
              name: 'idx_exp_oevpad_train_trainlocations_on_adapter_id'
  end
end
