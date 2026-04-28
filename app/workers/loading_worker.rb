class LoadingWorker
  include Sidekiq::Worker
  sidekiq_options queue: "ETL", retry: 3

  def perform(adapter_id, endpoint_id, execution_log_id, transformed_payload)
    adapter = Adapter.find(adapter_id)
    endpoint = Endpoint.find(endpoint_id)
    execution_log = ExecutionLog.find(execution_log_id)

    records = Array(transformed_payload)
    return 0 if records.empty?

    existing_hashes = Set.new(
      StoredDatum.where(adapter: adapter, endpoint: endpoint)
                 .pluck(:record_hash)
    )

    new_records = records.filter_map do |record|
      hash = Digest::SHA256.hexdigest(record.to_json)
      next if existing_hashes.include?(hash)
      [record, hash]
    end

    return 0 if new_records.empty?

    now = Time.current
    rows = new_records.map do |record, hash|
      {
        adapter_id: adapter.id,
        endpoint_id: endpoint.id,
        execution_log_id: execution_log.id,
        data: record,
        record_hash: hash,
        created_at: now,
        updated_at: now
      }
    end

    StoredDatum.insert_all(rows)
    rows.size
  end
end
