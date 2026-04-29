class CreateImpDilocTrains < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :imp_diloc_trains, id: :uuid do |t|
      t.date :day, null: false
      t.string :train_nr, null: false
      t.string :stop_point_ref
      t.string :stop_point_name
      t.string :stop_type
      t.datetime :aimed_arrival_time
      t.datetime :aimed_departure_time
      t.integer :sort, null: false, default: 0
      t.timestamps
    end

    add_index :imp_diloc_trains, [:train_nr, :day, :stop_point_ref],
              name: 'idx_imp_diloc_trains_on_train_nr_day_stop_point_ref'
  end
end
