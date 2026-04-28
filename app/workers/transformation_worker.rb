class TransformationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "ETL", retry: 3

  def perform(endpoint_id, raw_payload)
    endpoint = Endpoint.find(endpoint_id)
    rules = endpoint.transformation_rules.where(enabled: true).order(position: :asc)

    return normalize_payload(raw_payload) if rules.empty?

    records = normalize_payload(raw_payload)
    records.map do |record|
      transformed = {}
      rules.each do |rule|
        value = resolve_path(record, rule.source_path)
        value = apply_expression(value, rule.transformation_expression) if rule.transformation_expression.present?
        value = cast_type(value, rule.target_type)
        value = rule.default_value if value.nil? && rule.default_value.present?
        transformed[rule.target_field] = value
      end
      transformed
    end
  end

  private

  def normalize_payload(payload)
    case payload
    when Array then payload
    when Hash
      data = payload["data"] || payload[:data]
      if data.is_a?(Array)
        data
      elsif data.is_a?(Hash)
        [data]
      else
        [payload]
      end
    else
      [{ raw: payload }]
    end
  end

  def resolve_path(record, path)
    parts = path.to_s.split(".")
    current = record
    parts.each do |part|
      return nil unless current.is_a?(Hash) || current.is_a?(Array)
      if match = part.match(/\A(.+)\[(\d+)\]\z/)
        key, index = match[1], match[2].to_i
        current = current[key]
        current = current[index] if current.is_a?(Array)
      else
        current = current.is_a?(Hash) ? current[part] : nil
      end
    end
    current
  end

  def apply_expression(value, expression)
    return value if expression.blank?
    case expression.strip
    when "upcase", "uppercase"
      value.to_s.upcase
    when "downcase", "lowercase"
      value.to_s.downcase
    when "strip"
      value.to_s.strip
    when "to_i", "to_integer"
      value.to_i
    when "to_f", "to_float"
      value.to_f
    when "presence"
      value.presence
    else
      value
    end
  end

  def cast_type(value, target_type)
    return nil if value.nil?
    case target_type
    when "string" then value.to_s
    when "integer" then value.to_i
    when "float" then value.to_f
    when "boolean" then ActiveModel::Type::Boolean.new.cast(value)
    when "datetime" then Time.parse(value.to_s) rescue nil
    when "json" then value.is_a?(String) ? JSON.parse(value) : value
    else value
    end
  end
end
