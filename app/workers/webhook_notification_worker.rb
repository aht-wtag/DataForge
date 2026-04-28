class WebhookNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default", retry: 5

  def perform(adapter_id, execution_log_id)
    adapter = Adapter.find_by(id: adapter_id)
    execution_log = ExecutionLog.find_by(id: execution_log_id)
    return unless adapter && execution_log

    Webhook::Notifier.call(adapter, execution_log)
  end
end
