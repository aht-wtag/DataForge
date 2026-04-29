# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_04_29_211948) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "adapter_runs", force: :cascade do |t|
    t.bigint "adapter_id", null: false
    t.string "name", null: false
    t.string "state", default: "new", null: false
    t.integer "progress", default: 0, null: false
    t.integer "timeout"
    t.jsonb "result"
    t.text "error"
    t.text "stack"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_adapter_runs_on_adapter_id"
    t.index ["created_at"], name: "index_adapter_runs_on_created_at"
    t.index ["state"], name: "index_adapter_runs_on_state"
  end

  create_table "adapters", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "base_url", null: false
    t.text "description"
    t.integer "rate_limit"
    t.integer "timeout"
    t.integer "status", default: 0, null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "adapter_type", default: 0, null: false
    t.jsonb "config", default: {}, null: false
    t.index ["adapter_type"], name: "index_adapters_on_adapter_type"
    t.index ["user_id", "archived_at"], name: "index_adapters_on_user_id_and_archived_at"
    t.index ["user_id"], name: "index_adapters_on_user_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.bigint "adapter_id", null: false
    t.string "name", null: false
    t.integer "credential_type", default: 0, null: false
    t.string "auth_header_name"
    t.text "encrypted_value"
    t.text "encrypted_value_iv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_credentials_on_adapter_id"
  end

  create_table "data_exports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "adapter_id", null: false
    t.integer "export_format", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.jsonb "filters", default: {}
    t.integer "record_count", default: 0
    t.bigint "file_size_bytes", default: 0
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_data_exports_on_adapter_id"
    t.index ["user_id"], name: "index_data_exports_on_user_id"
  end

  create_table "diloc_statuses", force: :cascade do |t|
    t.integer "state", default: 0, null: false
    t.datetime "last_synced"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id = 1", name: "chk_diloc_status_single_row"
  end

  create_table "endpoints", force: :cascade do |t|
    t.bigint "adapter_id", null: false
    t.integer "http_method", default: 0, null: false
    t.string "path", null: false
    t.string "name", null: false
    t.text "description"
    t.jsonb "headers", default: {}
    t.jsonb "payload_template", default: {}
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_endpoints_on_adapter_id"
  end

  create_table "execution_logs", force: :cascade do |t|
    t.bigint "adapter_id", null: false
    t.bigint "endpoint_id"
    t.bigint "job_schedule_id"
    t.integer "status", default: 0, null: false
    t.integer "records_extracted", default: 0
    t.integer "records_transformed", default: 0
    t.integer "records_loaded", default: 0
    t.text "error_message"
    t.text "error_trace"
    t.jsonb "raw_payload"
    t.jsonb "transformed_payload"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "duration_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_execution_logs_on_adapter_id"
    t.index ["endpoint_id"], name: "index_execution_logs_on_endpoint_id"
    t.index ["job_schedule_id"], name: "index_execution_logs_on_job_schedule_id"
  end

  create_table "exp_oevpad_train_operationdays", force: :cascade do |t|
    t.uuid "adapter_id", null: false
    t.text "code_op_period", null: false
    t.datetime "date", null: false
    t.string "period_key", null: false
    t.uuid "adapter_id_timetable_period", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "idx_exp_oevpad_train_operationdays_on_date", unique: true
  end

  create_table "exp_oevpad_train_timetableperiods", force: :cascade do |t|
    t.uuid "adapter_id", null: false
    t.date "date_period_start", null: false
    t.date "date_period_end", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "idx_exp_oevpad_train_timetableperiods_on_adapter_id", unique: true
  end

  create_table "exp_oevpad_train_trainlocations", force: :cascade do |t|
    t.uuid "adapter_id", null: false
    t.uuid "adapter_id_train", null: false
    t.uuid "adapter_id_location", null: false
    t.string "loc_abbreviation", null: false
    t.uuid "adapter_id_timetable_period", null: false
    t.string "time_arrival"
    t.integer "offset_arrival", default: 0, null: false
    t.string "time_departure"
    t.integer "offset_departure"
    t.string "track_info"
    t.string "type_stop", null: false
    t.integer "sort", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "idx_exp_oevpad_train_trainlocations_on_adapter_id", unique: true
  end

  create_table "exp_oevpad_train_trains", force: :cascade do |t|
    t.uuid "adapter_id", null: false
    t.string "train_nr", null: false
    t.string "train_part"
    t.text "code_op_period", null: false
    t.datetime "break_series"
    t.uuid "adapter_id_timetable_period", null: false
    t.boolean "on_request", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "idx_exp_oevpad_train_trains_on_adapter_id", unique: true
  end

  create_table "imp_diloc_trains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "day", null: false
    t.string "train_nr", null: false
    t.string "stop_point_ref"
    t.string "stop_point_name"
    t.string "stop_type"
    t.datetime "aimed_arrival_time"
    t.datetime "aimed_departure_time"
    t.integer "sort", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["train_nr", "day", "stop_point_ref"], name: "idx_imp_diloc_trains_on_train_nr_day_stop_point_ref"
  end

  create_table "job_schedules", force: :cascade do |t|
    t.bigint "adapter_id", null: false
    t.bigint "endpoint_id", null: false
    t.string "cron_expression", null: false
    t.string "timezone", default: "UTC", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_run_at"
    t.datetime "next_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_job_schedules_on_adapter_id"
    t.index ["endpoint_id"], name: "index_job_schedules_on_endpoint_id"
  end

  create_table "schema_versions", force: :cascade do |t|
    t.string "version", null: false
    t.string "name", null: false
    t.integer "success", default: 0, null: false
    t.text "error_message"
    t.datetime "ran_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["version"], name: "index_schema_versions_on_version", unique: true
  end

  create_table "std_train_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "abbreviation", null: false
    t.string "name", null: false
    t.string "provider", default: "diloc", null: false
    t.string "provider_id", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "idx_std_train_locations_on_provider_id", unique: true
  end

  create_table "std_train_operationperiods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "idx_std_train_operationperiods_on_code", unique: true
  end

  create_table "std_train_operationperiods_days", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "std_train_operationperiod_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["std_train_operationperiod_id", "date"], name: "idx_std_train_opperiods_days_on_period_id_and_date", unique: true
    t.index ["std_train_operationperiod_id"], name: "idx_on_std_train_operationperiod_id_304aabab2e"
  end

  create_table "std_train_timetableperiods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date_period_start", null: false
    t.date "date_period_end", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "std_train_timetables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "std_train_train_id", null: false
    t.uuid "std_train_location_id", null: false
    t.uuid "std_train_timetableperiod_id", null: false
    t.string "time_arrival"
    t.string "time_departure"
    t.integer "offset_departure", default: 0, null: false
    t.string "type_stop"
    t.integer "sort", default: 0, null: false
    t.string "provider_id", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["std_train_location_id"], name: "index_std_train_timetables_on_std_train_location_id"
    t.index ["std_train_timetableperiod_id"], name: "index_std_train_timetables_on_std_train_timetableperiod_id"
    t.index ["std_train_train_id", "std_train_location_id", "std_train_timetableperiod_id", "provider_id"], name: "idx_std_train_timetables_unique", unique: true
    t.index ["std_train_train_id"], name: "index_std_train_timetables_on_std_train_train_id"
  end

  create_table "std_train_trains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "train_nr", null: false
    t.uuid "std_train_operationperiod_id", null: false
    t.string "break_series"
    t.uuid "std_train_timetableperiod_id", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["std_train_operationperiod_id"], name: "index_std_train_trains_on_std_train_operationperiod_id"
    t.index ["std_train_timetableperiod_id"], name: "index_std_train_trains_on_std_train_timetableperiod_id"
    t.index ["train_nr", "std_train_operationperiod_id"], name: "idx_std_train_trains_on_train_nr_and_op_period_id", unique: true
  end

  create_table "stored_data", force: :cascade do |t|
    t.bigint "adapter_id", null: false
    t.bigint "endpoint_id", null: false
    t.bigint "execution_log_id"
    t.jsonb "data", default: {}, null: false
    t.string "record_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_stored_data_on_adapter_id"
    t.index ["data"], name: "index_stored_data_on_data", using: :gin
    t.index ["endpoint_id"], name: "index_stored_data_on_endpoint_id"
    t.index ["execution_log_id"], name: "index_stored_data_on_execution_log_id"
    t.index ["record_hash"], name: "index_stored_data_on_record_hash", unique: true
  end

  create_table "transformation_rules", force: :cascade do |t|
    t.bigint "endpoint_id", null: false
    t.string "source_path", null: false
    t.string "target_field", null: false
    t.integer "target_type", default: 0, null: false
    t.string "default_value"
    t.text "transformation_expression"
    t.integer "position", default: 0, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint_id"], name: "index_transformation_rules_on_endpoint_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 2, null: false
    t.string "api_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "adapter_runs", "adapters"
  add_foreign_key "adapters", "users"
  add_foreign_key "credentials", "adapters"
  add_foreign_key "data_exports", "adapters"
  add_foreign_key "data_exports", "users"
  add_foreign_key "endpoints", "adapters"
  add_foreign_key "execution_logs", "adapters"
  add_foreign_key "execution_logs", "endpoints"
  add_foreign_key "execution_logs", "job_schedules"
  add_foreign_key "job_schedules", "adapters"
  add_foreign_key "job_schedules", "endpoints"
  add_foreign_key "std_train_operationperiods_days", "std_train_operationperiods"
  add_foreign_key "std_train_timetables", "std_train_locations"
  add_foreign_key "std_train_timetables", "std_train_timetableperiods"
  add_foreign_key "std_train_timetables", "std_train_trains"
  add_foreign_key "std_train_trains", "std_train_operationperiods"
  add_foreign_key "std_train_trains", "std_train_timetableperiods"
  add_foreign_key "stored_data", "adapters"
  add_foreign_key "stored_data", "endpoints"
  add_foreign_key "stored_data", "execution_logs"
  add_foreign_key "transformation_rules", "endpoints"
end
