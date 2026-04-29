module Adapters
  module DiLoc
    class ReadDiLoc
      EXCLUDED_STOPS = %w[UMLR ROHR INGA SENG].freeze
      TRAIN_9XX_PATTERN = /\A9\d\d\z/
      TRAILING_SUFFIX_PATTERN = /\.\d+\z/
      BATCH_SIZE = 300

      def get_trains(config)
        start_time = calculate_start_time(config)
        end_time = calculate_end_time(config)

        api = DiLocApiService.new(
          base_url: config[:DiLocBaseurl],
          start_time: start_time,
          end_time: end_time,
          api_key: config[:apiKey],
          ssl_verify: config.fetch(:oevpadCockpiturlSslRejectUnauthorized, true)
        )

        train_data = api.fetch_all
        last_sync = last_successful_sync_time

        { data: train_data, start_time: last_sync }
      end

      def import_trains(train_data)
        return 0 if train_data.blank?

        consolidated = consolidate_train_data(train_data)

        ImpDiLocTrain.truncate!

        rows = build_rows(consolidated)
        ImpDiLocTrain.bulk_import!(rows, batch_size: BATCH_SIZE)

        rows.size
      end

      def last_successful_sync_time
        status = DiLocStatus.instance
        status.success? ? status.last_synced : nil
      end

      private

      def calculate_start_time(config)
        return Time.parse(config[:startDateTime]) if config[:startDateTime].present?

        t = Time.current
        config[:reset] ? t.beginning_of_day : t
      end

      def calculate_end_time(config)
        return Time.parse(config[:endDateTime]) if config[:endDateTime].present?

        offset = config[:offsetHours].to_i
        offset > 0 ? Time.current + offset.hours : Time.current + 24.hours
      end

      def consolidate_train_data(train_data)
        result = {}

        train_data.each do |train|
          train_nr = train['TrainNumberRef'].to_s
          date = train['DataFrameRef']

          next if train_nr.match?(TRAIN_9XX_PATTERN)

          train_nr = train_nr.sub(TRAILING_SUFFIX_PATTERN, '')

          result[train_nr] ||= {}
          result[train_nr][date] ||= {}

          (train['Calls'] || []).each do |call|
            stop_ref = call['StopPointRef']
            next if stop_ref.blank? || EXCLUDED_STOPS.include?(stop_ref)

            existing = result[train_nr][date][stop_ref] || {}
            result[train_nr][date][stop_ref] = merge_call(existing, call)
          end
        end

        result
      end

      def merge_call(existing, incoming)
        incoming.each do |key, value|
          existing[key] ||= value
        end
        existing
      end

      def build_rows(consolidated)
        rows = []

        consolidated.each do |train_nr, dates|
          dates.each do |date, stops|
            sort = 1
            stops.each do |_stop_ref, call|
              rows << {
                id: SecureRandom.uuid,
                day: Date.parse(date.to_s),
                train_nr: train_nr,
                stop_point_ref: call['StopPointRef'],
                stop_point_name: call['StopPointName'],
                stop_type: call['StopType'],
                aimed_arrival_time: parse_time_value(call['AimedArrivalTime']),
                aimed_departure_time: parse_time_value(call['AimedDepartureTime']),
                sort: sort
              }
              sort += 1
            end
          end
        end

        rows
      end

      def parse_time_value(value)
        return nil if value.blank?
        Time.parse(value.to_s)
      rescue ArgumentError
        nil
      end
    end
  end
end
