class LogCleanupWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default", retry: 3

  RETENTION_DAYS = 90

  def perform(retention_days = RETENTION_DAYS)
    cutoff = retention_days.days.ago

    logs = ExecutionLog.where("created_at < ?", cutoff)
    count = logs.count

    if count > 0
      StoredDatum.where(execution_log: logs).delete_all
      logs.delete_all
    end

    Rails.logger.info("LogCleanupWorker: deleted #{count} execution logs older than #{retention_days} days")
  end
end
