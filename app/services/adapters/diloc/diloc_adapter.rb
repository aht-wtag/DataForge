module Adapters
  module DiLoc
    class DiLocAdapter < BaseAdapter
      TOTAL_STEPS = 4

      def initialize(adapter_record, config: {})
        super
        @reader = ReadDiLoc.new
        @std_transformer = TransformDiLocToStandard.new
        @exp_transformer = TransformStandardToOevpadTrain.new
        @sync_service = DiLocTrainsSync.new
        @cleanup = DiLocCleanup.new
        @last_sync_time = nil
      end

      def do_run
        Rails.logger.info("DiLocAdapter: Starting run for adapter #{adapter_record.id}")

        @cleanup.truncate_all if config[:reset]

        begin
          execute_import
          set_progress(1, TOTAL_STEPS)

          execute_transform_to_standard
          set_progress(2, TOTAL_STEPS)

          execute_transform_to_export
          set_progress(3, TOTAL_STEPS)

          execute_cockpit_sync
          set_progress(4, TOTAL_STEPS)

          update_last_successful_sync

          { status: 'success', adapter_id: adapter_record.id }
        rescue => e
          mark_sync_failure
          Rails.logger.error("DiLocAdapter: Run failed — #{e.message}")
          raise
        end
      end

      private

      def execute_import
        set_state('import')
        Rails.logger.info("DiLocAdapter: Phase 1 — Import")

        train_result = @reader.get_trains(config)
        @last_sync_time = train_result[:start_time]
        imported_count = @reader.import_trains(train_result[:data])

        Rails.logger.info("DiLocAdapter: Imported #{imported_count} records")
      end

      def execute_transform_to_standard
        set_state('transform_to_standard')
        Rails.logger.info("DiLocAdapter: Phase 2 — Transform to Standard")

        @std_transformer.execute
      end

      def execute_transform_to_export
        set_state('transform_to_export')
        Rails.logger.info("DiLocAdapter: Phase 3 — Transform to Export")

        @exp_transformer.execute
      end

      def execute_cockpit_sync
        set_state('send_to_cockpit')
        Rails.logger.info("DiLocAdapter: Phase 4 — Sync to Cockpit")

        cockpit_url = config[:oevpadCockpiturl]
        api_key = config[:CockpitApiKey]

        raise "Missing cockpit URL (oevpadCockpiturl)" if cockpit_url.blank?
        raise "Missing cockpit API key (CockpitApiKey)" if api_key.blank?

        @sync_service.sync(
          cockpit_url: cockpit_url,
          api_key: api_key,
          last_sync_time: @last_sync_time,
          reset: config[:reset] || false
        )
      end

      def update_last_successful_sync
        DiLocStatus.instance.mark_success!
        Rails.logger.info("DiLocAdapter: Marked sync as successful")
      end

      def mark_sync_failure
        DiLocStatus.instance.mark_failure!
      end
    end
  end
end
