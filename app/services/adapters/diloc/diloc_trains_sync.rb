module Adapters
  module DiLoc
    class DiLocTrainsSync
      BASE_ENDPOINT = '/ifs/diloc'
      CHUNK_SIZE = 1000

      def initialize
        @cockpit_url = nil
        @api_key = nil
        @reset = false
      end

      def sync(cockpit_url:, api_key:, last_sync_time: nil, reset: false)
        @cockpit_url = cockpit_url
        @api_key = api_key
        @reset = reset

        timetable_data = fetch_delta(ExpOevpadTrainTimetableperiod, last_sync_time)
        operation_day_data = fetch_delta(ExpOevpadTrainOperationday, last_sync_time)
        train_data = fetch_delta(ExpOevpadTrainTrain, last_sync_time)
        train_location_data = fetch_delta(ExpOevpadTrainTrainlocation, last_sync_time)

        sync_timetable(timetable_data)
        sync_operation_day(operation_day_data)
        sync_train(train_data)
        sync_train_locations(train_location_data)

        Rails.logger.info("DiLocTrainsSync: Cockpit sync completed")
      end

      private

      def fetch_delta(model_class, last_sync_time)
        now = Time.current
        scope = model_class.up_to_now
        scope = scope.delta_since(last_sync_time) if last_sync_time.present?
        scope = scope.active if last_sync_time.blank?

        {
          timestamp: now.iso8601,
          updated: scope.as_json(only: serialize_fields(model_class))
        }
      end

      def serialize_fields(model_class)
        case model_class.name
        when 'ExpOevpadTrainTimetableperiod'
          %i[adapter_id date_period_start date_period_end deleted]
        when 'ExpOevpadTrainOperationday'
          %i[adapter_id code_op_period date period_key adapter_id_timetable_period deleted]
        when 'ExpOevpadTrainTrain'
          %i[adapter_id train_nr train_part code_op_period break_series adapter_id_timetable_period on_request deleted]
        when 'ExpOevpadTrainTrainlocation'
          %i[adapter_id adapter_id_train adapter_id_location loc_abbreviation adapter_id_timetable_period time_arrival offset_arrival time_departure offset_departure track_info type_stop sort deleted]
        else
          []
        end
      end

      def sync_timetable(data)
        post_to_cockpit(data, 'timetablePeriod')
      end

      def sync_operation_day(data)
        post_to_cockpit(data, 'operationDay')
      end

      def sync_train(data)
        post_to_cockpit(data, 'train')
      end

      def sync_train_locations(data)
        locations = data[:updated]
        return if locations.blank?

        if locations.length <= CHUNK_SIZE
          payload = data.merge(pagination: { page: 1, totalPages: 1 })
          post_to_cockpit(payload, 'trainTrainLocation')
          return
        end

        total_pages = (locations.length / CHUNK_SIZE.to_f).ceil
        locations.each_slice(CHUNK_SIZE).with_index do |chunk, i|
          payload = {
            timestamp: data[:timestamp],
            updated: chunk,
            pagination: { page: i + 1, totalPages: total_pages }
          }
          post_to_cockpit(payload, 'trainTrainLocation', reset_flag: @reset && i == 0)
        end
      end

      def post_to_cockpit(data, endpoint, reset_flag: nil)
        uri = URI.parse("#{@cockpit_url}#{BASE_ENDPOINT}/#{endpoint}")

        body = {
          reset: reset_flag.nil? ? @reset : reset_flag,
          timestamp: data[:timestamp],
          updated: data[:updated]
        }
        body[:pagination] = data[:pagination] if data[:pagination]

        options = {
          headers: build_headers,
          body: body.to_json,
          timeout: 120,
          verify: true
        }

        response = HTTParty.post(uri.to_s, options)

        if response.success?
          Rails.logger.info("DiLocTrainsSync: POST #{endpoint} — #{response.code}")
        else
          raise "Cockpit sync failed for #{endpoint}: HTTP #{response.code} — #{response.body}"
        end
      rescue HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Cockpit POST failed for #{endpoint}: #{e.message}"
      end

      def build_headers
        {
          'Content-Type' => 'application/json; charset=UTF-8',
          'X-API-Key' => @api_key,
          'Accept-Encoding' => 'gzip, deflate, br'
        }
      end
    end
  end
end
