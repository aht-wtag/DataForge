module Adapters
  module DiLoc
    class TransformStandardToOevpadTrain
      TYPE_STOP_MAP = {
        'passthrough' => 'pass',
        'halt' => 'stop',
        'conditional_halt' => 'onRequest',
        'exceptional_halt' => 'stop',
        'technical_halt' => 'pass',
        'only_exit' => 'stop',
        'touristic_halt' => 'stop'
      }.freeze

      def execute
        export_timetable_period
        export_operation_day
        export_train
        export_train_locations

        Rails.logger.info("DiLoc export transformation completed")
      rescue => e
        Rails.logger.error("DiLoc export transformation failed: #{e.message}")
        raise
      end

      private

      def export_timetable_period
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO exp_oevpad_train_timetableperiods (
              adapter_id, date_period_start, date_period_end,
              deleted, created_at, updated_at
          )
          SELECT id, date_period_start, date_period_end, false, NOW(), NOW()
          FROM std_train_timetableperiods
          WHERE deleted = false
          ON CONFLICT (adapter_id) DO UPDATE SET
              date_period_start = EXCLUDED.date_period_start,
              date_period_end = EXCLUDED.date_period_end,
              updated_at = NOW()
        SQL
      end

      def export_operation_day
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO exp_oevpad_train_operationdays (
              adapter_id, code_op_period, date, period_key,
              adapter_id_timetable_period, deleted, created_at, updated_at
          )
          SELECT
              sod.id,
              op.code,
              sod.date,
              md5(op.code),
              stp.id,
              false, NOW(), NOW()
          FROM std_train_operationperiods_days sod
          JOIN std_train_operationperiods op
              ON op.id = sod.std_train_operationperiod_id
          JOIN std_train_timetableperiods stp
              ON sod.date BETWEEN stp.date_period_start AND stp.date_period_end
          WHERE stp.deleted = false
          ON CONFLICT (date) DO UPDATE SET
              code_op_period = EXCLUDED.code_op_period,
              period_key = EXCLUDED.period_key,
              adapter_id_timetable_period = EXCLUDED.adapter_id_timetable_period,
              updated_at = NOW()
        SQL
      end

      def export_train
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO exp_oevpad_train_trains (
              adapter_id, train_nr, train_part, code_op_period,
              break_series, adapter_id_timetable_period,
              on_request, deleted, created_at, updated_at
          )
          SELECT
              stt.id,
              stt.train_nr,
              concat('tp-', stt.train_nr),
              op.code,
              stt.break_series,
              stt.std_train_timetableperiod_id,
              false,
              stt.deleted,
              NOW(), NOW()
          FROM std_train_trains stt
          JOIN std_train_operationperiods op
              ON op.id = stt.std_train_operationperiod_id
          WHERE stt.deleted = false
          ON CONFLICT (adapter_id) DO UPDATE SET
              updated_at = CASE
                  WHEN EXCLUDED.train_nr IS DISTINCT FROM exp_oevpad_train_trains.train_nr
                    OR EXCLUDED.train_part IS DISTINCT FROM exp_oevpad_train_trains.train_part
                    OR EXCLUDED.code_op_period IS DISTINCT FROM exp_oevpad_train_trains.code_op_period
                    OR EXCLUDED.break_series IS DISTINCT FROM exp_oevpad_train_trains.break_series
                    OR EXCLUDED.adapter_id_timetable_period IS DISTINCT FROM exp_oevpad_train_trains.adapter_id_timetable_period
                    OR EXCLUDED.deleted IS DISTINCT FROM exp_oevpad_train_trains.deleted
                  THEN NOW()
                  ELSE exp_oevpad_train_trains.updated_at
              END,
              train_nr = EXCLUDED.train_nr,
              train_part = EXCLUDED.train_part,
              code_op_period = EXCLUDED.code_op_period,
              break_series = EXCLUDED.break_series,
              adapter_id_timetable_period = EXCLUDED.adapter_id_timetable_period,
              deleted = EXCLUDED.deleted
        SQL
      end

      def export_train_locations
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO exp_oevpad_train_trainlocations (
              adapter_id, adapter_id_train, adapter_id_location,
              loc_abbreviation, adapter_id_timetable_period,
              time_arrival, offset_arrival,
              time_departure, offset_departure,
              track_info, type_stop, sort,
              deleted, deleted_at, created_at, updated_at
          )
          SELECT
              stt.id,
              train.id,
              loc.id,
              loc.abbreviation,
              tp.id,
              stt.time_arrival,
              0,
              stt.time_departure,
              stt.offset_departure,
              NULL,
              #{type_stop_case_sql},
              stt.sort,
              stt.deleted,
              stt.deleted_at,
              NOW(), NOW()
          FROM std_train_timetables stt
          JOIN std_train_trains train ON stt.std_train_train_id = train.id
          JOIN std_train_locations loc ON stt.std_train_location_id = loc.id
          JOIN std_train_timetableperiods tp ON stt.std_train_timetableperiod_id = tp.id
          ON CONFLICT (adapter_id) DO UPDATE SET
              updated_at = CASE
                  WHEN exp_oevpad_train_trainlocations.adapter_id_timetable_period IS NOT DISTINCT FROM EXCLUDED.adapter_id_timetable_period
                   AND exp_oevpad_train_trainlocations.time_arrival IS NOT DISTINCT FROM EXCLUDED.time_arrival
                   AND exp_oevpad_train_trainlocations.time_departure IS NOT DISTINCT FROM EXCLUDED.time_departure
                   AND exp_oevpad_train_trainlocations.offset_departure IS NOT DISTINCT FROM EXCLUDED.offset_departure
                   AND exp_oevpad_train_trainlocations.loc_abbreviation IS NOT DISTINCT FROM EXCLUDED.loc_abbreviation
                   AND exp_oevpad_train_trainlocations.type_stop IS NOT DISTINCT FROM EXCLUDED.type_stop
                   AND exp_oevpad_train_trainlocations.deleted IS NOT DISTINCT FROM EXCLUDED.deleted
                   AND exp_oevpad_train_trainlocations.deleted_at IS NOT DISTINCT FROM EXCLUDED.deleted_at
                   AND exp_oevpad_train_trainlocations.sort IS NOT DISTINCT FROM EXCLUDED.sort
                  THEN exp_oevpad_train_trainlocations.updated_at
                  ELSE NOW()
              END,
              adapter_id_timetable_period = EXCLUDED.adapter_id_timetable_period,
              time_arrival = EXCLUDED.time_arrival,
              time_departure = EXCLUDED.time_departure,
              offset_departure = EXCLUDED.offset_departure,
              type_stop = EXCLUDED.type_stop,
              sort = EXCLUDED.sort,
              deleted = EXCLUDED.deleted,
              deleted_at = EXCLUDED.deleted_at
        SQL
      end

      def type_stop_case_sql
        whens = TYPE_STOP_MAP.map { |k, v| "WHEN '#{k}' THEN '#{v}'" }.join("\n                  ")
        "CASE stt.type_stop\n                  #{whens}\n                  ELSE 'stop'\n              END"
      end
    end
  end
end
