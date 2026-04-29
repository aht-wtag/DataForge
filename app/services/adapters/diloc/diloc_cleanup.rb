module Adapters
  module DiLoc
    class DiLocCleanup
      EXPORT_TABLES = %w[
        exp_oevpad_train_operationdays
        exp_oevpad_train_timetableperiods
        exp_oevpad_train_trains
        exp_oevpad_train_trainlocations
      ].freeze

      STANDARD_TABLES = %w[
        std_train_locations
        std_train_operationperiods
        std_train_operationperiods_days
        std_train_timetables
        std_train_trains
      ].freeze

      IMPORT_TABLES = %w[
        imp_diloc_trains
      ].freeze

      ALL_TABLES = (EXPORT_TABLES + STANDARD_TABLES + IMPORT_TABLES).freeze

      def truncate_all
        truncate(EXPORT_TABLES + STANDARD_TABLES)
        Rails.logger.info("DiLocCleanup: Truncated export and standard tables")
      end

      def truncate_export_tables
        truncate(EXPORT_TABLES)
        Rails.logger.info("DiLocCleanup: Truncated export tables")
      end

      def truncate_standard_tables
        truncate(STANDARD_TABLES)
        Rails.logger.info("DiLocCleanup: Truncated standard tables")
      end

      def truncate_import_tables
        truncate(IMPORT_TABLES)
        Rails.logger.info("DiLocCleanup: Truncated import tables")
      end

      def truncate_all_including_import
        truncate(ALL_TABLES)
        Rails.logger.info("DiLocCleanup: Truncated all DiLoc tables")
      end

      private

      def truncate(tables)
        tables.each do |table|
          ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE")
        end
      rescue ActiveRecord::StatementInvalid => e
        Rails.logger.error("DiLocCleanup: Truncation failed — #{e.message}")
        raise
      end
    end
  end
end
