module Webhook
  class Notifier
    HMAC_SECRET = ENV.fetch("WEBHOOK_HMAC_SECRET") { "default_secret" } # TODO: Add webhook_url column to adapters table (Phase 20)

    def self.call(adapter, execution_log)
      return unless adapter.respond_to?(:webhook_url) && adapter.webhook_url.present?

      payload = {
        event: "execution.#{execution_log.status}",
        adapter_id: adapter.id,
        execution_log_id: execution_log.id,
        status: execution_log.status,
        records_loaded: execution_log.records_loaded,
        timestamp: Time.current.iso8601
      }

      signature = OpenSSL::HMAC.hexdigest("SHA256", HMAC_SECRET, payload.to_json)

      HTTParty.post(adapter.webhook_url, {
        body: payload.to_json,
        headers: {
          "Content-Type" => "application/json",
          "X-DataForge-Signature" => signature,
          "X-DataForge-Event" => "execution.#{execution_log.status}"
        },
        timeout: 10
      })
    end
  end
end
