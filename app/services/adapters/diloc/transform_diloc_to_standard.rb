module Adapters
  module DiLoc
    class TransformDiLocToStandard
      def execute
        ActiveRecord::Base.transaction do
          set_code
          set_operation_period
          map_trains_per_day
          store_train_locations
          set_train_timetables
          clean_up_orphaned_timetable_entries
        end

        Rails.logger.info("DiLoc standard transformation completed")
      rescue => e
        Rails.logger.error("DiLoc standard transformation failed: #{e.message}")
        raise
      end

      private

      def set_code
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO std_train_operationperiods (code, created_at, updated_at)
          SELECT DISTINCT idt.day::text, NOW(), NOW()
          FROM imp_diloc_trains AS idt
          WHERE NOT EXISTS (
              SELECT 1 FROM std_train_operationperiods
              WHERE code = idt.day::text
          )
        SQL
      end

      def set_operation_period
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO std_train_operationperiods_days (std_train_operationperiod_id, date, created_at, updated_at)
          SELECT sto.id, sto.code::date, NOW(), NOW()
          FROM std_train_operationperiods AS sto
          WHERE NOT EXISTS (
              SELECT 1 FROM std_train_operationperiods_days
              WHERE std_train_operationperiod_id = sto.id
          )
          ON CONFLICT (std_train_operationperiod_id, date) DO NOTHING
        SQL
      end

      def map_trains_per_day
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO std_train_trains (train_nr, std_train_operationperiod_id, std_train_timetableperiod_id, created_at, updated_at)
          SELECT sub.train_nr, sub.op_id, sub.tp_id, NOW(), NOW()
          FROM (
              SELECT DISTINCT idt.train_nr, op.id AS op_id, tp.id AS tp_id
              FROM imp_diloc_trains idt
              JOIN std_train_operationperiods_days opd ON idt.day = opd.date
              JOIN std_train_operationperiods op ON op.id = opd.std_train_operationperiod_id
              JOIN std_train_timetableperiods tp ON idt.day BETWEEN tp.date_period_start AND tp.date_period_end
              WHERE tp.deleted = false
          ) sub
          ON CONFLICT (train_nr, std_train_operationperiod_id) DO UPDATE SET updated_at = NOW()
        SQL
      end

      def store_train_locations
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO std_train_locations (abbreviation, name, provider_id, created_at, updated_at)
          SELECT sub.abbreviation, sub.name, sub.provider_id, NOW(), NOW()
          FROM (
              SELECT DISTINCT stop_point_ref AS abbreviation,
                  stop_point_name AS name,
                  stop_point_ref AS provider_id
              FROM imp_diloc_trains
              WHERE stop_point_ref IS NOT NULL
                AND stop_point_name IS NOT NULL
          ) sub
          ON CONFLICT (provider_id) DO UPDATE SET
              name = EXCLUDED.name,
              updated_at = NOW()
        SQL
      end

      def set_train_timetables
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO std_train_timetables (
              std_train_train_id, std_train_location_id, std_train_timetableperiod_id,
              time_arrival, time_departure, offset_departure,
              type_stop, sort, provider_id, created_at, updated_at
          )
          SELECT
              tt.id,
              stl.id,
              tp.id,
              to_char(idt.aimed_arrival_time, 'HH24:MI:SS'),
              to_char(idt.aimed_departure_time, 'HH24:MI:SS'),
              0,
              COALESCE(idt.stop_type, 'halt'),
              ROW_NUMBER() OVER (
                  PARTITION BY idt.train_nr, idt.day
                  ORDER BY idt.day, idt.aimed_arrival_time, idt.aimed_departure_time
              ),
              md5(concat(tt.id::text, stl.id::text, tp.id::text, idt.train_nr, idt.day::text, COALESCE(idt.stop_point_ref, ''))),
              NOW(), NOW()
          FROM imp_diloc_trains idt
          JOIN std_train_operationperiods_days opd ON opd.date = idt.day
          JOIN std_train_operationperiods op ON op.id = opd.std_train_operationperiod_id
          JOIN std_train_trains tt ON tt.train_nr = idt.train_nr
              AND tt.std_train_operationperiod_id = op.id
          JOIN std_train_locations stl ON stl.abbreviation = idt.stop_point_ref
          JOIN std_train_timetableperiods tp ON idt.day BETWEEN tp.date_period_start
              AND tp.date_period_end
          WHERE idt.stop_point_ref IS NOT NULL
            AND tp.deleted = false
            AND tt.deleted = false
            AND stl.deleted = false
          ON CONFLICT (std_train_train_id, std_train_location_id, std_train_timetableperiod_id, provider_id) DO UPDATE SET
              time_arrival = EXCLUDED.time_arrival,
              time_departure = EXCLUDED.time_departure,
              type_stop = EXCLUDED.type_stop,
              deleted = false,
              deleted_at = NULL,
              updated_at = NOW()
        SQL
      end

      def clean_up_orphaned_timetable_entries
        ActiveRecord::Base.connection.execute(<<~SQL)
          UPDATE std_train_timetables
          SET deleted = true, updated_at = NOW(), deleted_at = NOW()
          FROM std_train_trains tt,
               std_train_operationperiods_days opd,
               std_train_timetableperiods tp
          WHERE std_train_timetables.std_train_train_id = tt.id
            AND tt.deleted = false
            AND tt.std_train_operationperiod_id = opd.std_train_operationperiod_id
            AND std_train_timetables.std_train_timetableperiod_id = tp.id
            AND tp.deleted = false
            AND std_train_timetables.deleted = false
            AND EXISTS (
                SELECT 1 FROM imp_diloc_trains idt
                WHERE idt.train_nr = tt.train_nr
                  AND idt.day = opd.date
            )
            AND NOT EXISTS (
                SELECT 1 FROM imp_diloc_trains idt2
                JOIN std_train_locations stl2
                    ON stl2.abbreviation = idt2.stop_point_ref
                    AND stl2.deleted = false
                JOIN std_train_timetableperiods tp2
                    ON idt2.day BETWEEN tp2.date_period_start AND tp2.date_period_end
                    AND tp2.deleted = false
                WHERE idt2.train_nr = tt.train_nr
                  AND idt2.day = opd.date
                  AND stl2.id = std_train_timetables.std_train_location_id
                  AND tp2.id = std_train_timetables.std_train_timetableperiod_id
            )
        SQL
      end
    end
  end
end
