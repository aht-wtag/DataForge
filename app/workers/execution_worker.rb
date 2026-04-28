class ExecutionWorker
  include Sidekiq::Worker
  sidekiq_options queue: "ETL", retry: 3

  def perform(adapter_id, endpoint_id, job_schedule_id = nil)
    adapter = Adapter.find(adapter_id)
    endpoint = Endpoint.find(endpoint_id)

    execution_log = ExecutionLog.create!(
      adapter: adapter,
      endpoint: endpoint,
      job_schedule_id: job_schedule_id,
      status: :running,
      started_at: Time.current
    )

    adapter.update!(status: :running)

    raw_payload = ExtractionWorker.new.perform(adapter_id, endpoint_id, execution_log.id)
    execution_log.update!(raw_payload: raw_payload, records_extracted: extract_count(raw_payload))

    transformed_payload = TransformationWorker.new.perform(endpoint_id, raw_payload)
    execution_log.update!(transformed_payload: transformed_payload, records_transformed: transformed_payload.size)

    records_loaded = LoadingWorker.new.perform(adapter_id, endpoint_id, execution_log.id, transformed_payload)
    execution_log.update!(records_loaded: records_loaded, status: :completed, finished_at: Time.current)
    execution_log.update_column(:duration_ms, ((Time.current - execution_log.started_at) * 1000).to_i)

    adapter.update!(status: :active)

    WebhookNotificationWorker.perform_async(adapter_id, execution_log.id)
  rescue => e
    if execution_log
      execution_log.update!(
        status: :failed,
        error_message: e.message,
        error_trace: e.backtrace&.first(10)&.join("\n"),
        finished_at: Time.current
      )
      execution_log.update_column(:duration_ms, ((Time.current - execution_log.started_at) * 1000).to_i) if execution_log.started_at
    end
    adapter&.update!(status: :error)
    raise
  end

  private

  def extract_count(payload)
    case payload
    when Array then payload.size
    when Hash then 1
    else 0
    end
  end
end
