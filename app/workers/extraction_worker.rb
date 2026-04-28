class ExtractionWorker
  include Sidekiq::Worker
  sidekiq_options queue: "ETL", retry: 3

  def perform(adapter_id, endpoint_id, execution_log_id)
    adapter = Adapter.find(adapter_id)
    endpoint = Endpoint.find(endpoint_id)

    credential = adapter.credentials.order(created_at: :desc).first
    headers = endpoint.headers || {}
    headers = build_auth_headers(credential, headers) if credential

    url = "#{adapter.base_url}#{endpoint.path}"

    options = { headers: headers, timeout: adapter.timeout || 30 }

    response = case endpoint.http_method
               when "get"
                 HTTParty.get(url, options)
               when "post"
                 HTTParty.post(url, options.merge(body: endpoint.payload_template&.to_json || {}))
               when "put"
                 HTTParty.put(url, options.merge(body: endpoint.payload_template&.to_json || {}))
               when "patch"
                 HTTParty.patch(url, options.merge(body: endpoint.payload_template&.to_json || {}))
               when "delete"
                 HTTParty.delete(url, options)
               else
                 HTTParty.get(url, options)
               end

    unless response.success?
      raise "Extraction failed: HTTP #{response.code} — #{response.message}"
    end

    parsed = response.parsed_response
    parsed.is_a?(Hash) || parsed.is_a?(Array) ? parsed : { raw: parsed.to_s }
  end

  private

  def build_auth_headers(credential, headers)
    case credential.credential_type
    when "bearer_token"
      headers["Authorization"] = "Bearer #{credential.value}"
    when "api_key"
      headers[credential.auth_header_name.presence || "X-API-Key"] = credential.value
    when "basic_auth"
      encoded = Base64.strict_encode64(credential.value)
      headers["Authorization"] = "Basic #{encoded}"
    when "custom_header"
      headers[credential.auth_header_name.presence || "X-Custom-Auth"] = credential.value
    end
    headers
  end
end
