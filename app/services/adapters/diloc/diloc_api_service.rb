module Adapters
  module DiLoc
    class DiLocApiService
      MAX_RANGE_SECONDS = 5 * 86400 + 2 * 3600
      CHUNK_DAYS = 1

      def initialize(base_url:, start_time:, end_time:, api_key:, ssl_verify: true)
        @base_url = base_url
        @start_time = parse_time(start_time)
        @end_time = parse_time(end_time)
        @api_key = api_key
        @ssl_verify = ssl_verify

        validate_range!
      end

      def fetch_all
        all_data = []
        current_start = @start_time

        while current_start < @end_time
          chunk_end = [current_start + CHUNK_DAYS.days, @end_time].min
          chunk = fetch_chunk(current_start, chunk_end)
          break if chunk.nil? || chunk.empty?

          all_data.concat(chunk)
          current_start = chunk_end
        end

        all_data
      end

      private

      def fetch_chunk(start_time, end_time)
        Rails.logger.info("DiLocApi: Fetching #{start_time.utc.iso8601} to #{end_time.utc.iso8601}")

        query = {
          "StartDateTime" => start_time.utc.iso8601,
          "EndDateTime" => end_time.utc.iso8601
        }

        uri = URI(@base_url)
        uri.query = URI.encode_www_form(query)

        options = {
          headers: build_headers,
          timeout: 60,
          verify: @ssl_verify
        }

        response = HTTParty.get(uri.to_s, options)

        unless response.success?
          raise "DiLoc API error: HTTP #{response.code} — #{response.message}"
        end

        parse_response(response.body)
      rescue HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout => e
        raise "DiLoc API request failed: #{e.message}"
      end

      def build_headers
        {
          "Content-Type" => "application/json",
          "X-API-Key" => @api_key
        }
      end

      def parse_response(body)
        return [] if body.blank?

        parsed = JSON.parse(body)
        case parsed
        when Array then parsed
        when Hash then [parsed]
        else []
        end
      rescue JSON::ParserError => e
        Rails.logger.error("DiLocApi: Failed to parse response: #{e.message}")
        []
      end

      def parse_time(value)
        case value
        when Time then value
        when String then Time.parse(value)
        when Date then value.beginning_of_day
        else raise ArgumentError, "Invalid time value: #{value.inspect}"
        end
      end

      def validate_range!
        range_seconds = @end_time.to_i - @start_time.to_i
        if range_seconds > MAX_RANGE_SECONDS
          raise ArgumentError, "Date range exceeds maximum of 5 days + 2 hours (#{range_seconds}s > #{MAX_RANGE_SECONDS}s)"
        end
        if @end_time <= @start_time
          raise ArgumentError, "End time (#{@end_time}) must be after start time (#{@start_time})"
        end
      end
    end
  end
end
