class DiLocAdapterJob
  include Sidekiq::Worker
  sidekiq_options queue: "ETL", retry: 3

  def perform(adapter_id, config_overrides = {})
    adapter = Adapter.find(adapter_id)

    config = build_config(adapter, config_overrides)

    diloc_adapter = Adapters::DiLoc::DiLocAdapter.new(adapter, config: config)
    diloc_adapter.run
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("DiLocAdapterJob: Adapter #{adapter_id} not found")
    raise
  rescue => e
    Rails.logger.error("DiLocAdapterJob: Failed for adapter #{adapter_id} — #{e.message}")
    raise
  end

  private

  def build_config(adapter, overrides = {})
    credentials = load_credentials(adapter)

    {
      DiLocBaseurl: adapter.base_url,
      apiKey: credentials[:api_key] || '',
      offsetHours: overrides[:offsetHours] || 48,
      startDateTime: overrides[:startDateTime],
      endDateTime: overrides[:endDateTime],
      oevpadCockpiturl: overrides[:oevpadCockpiturl] || adapter.base_url,
      CockpitApiKey: credentials[:cockpit_api_key] || credentials[:api_key] || '',
      oevpadCockpiturlSslRejectUnauthorized: overrides[:oevpadCockpiturlSslRejectUnauthorized] || true,
      reset: overrides[:reset] || false
    }.merge(overrides.symbolize_keys)
  end

  def load_credentials(adapter)
    creds = {}
    adapter.credentials.each do |cred|
      case cred.name&.downcase
      when /diloc/, /api/
        creds[:api_key] = cred.value
      when /cockpit/
        creds[:cockpit_api_key] = cred.value
      end
    end
    creds
  end
end
