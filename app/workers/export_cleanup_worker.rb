class ExportCleanupWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default", retry: 3

  RETENTION_DAYS = 30

  def perform(retention_days = RETENTION_DAYS)
    cutoff = retention_days.days.ago

    exports = DataExport.where("created_at < ?", cutoff)
    count = exports.count

    exports.find_each do |export|
      export.export_file.purge if export.export_file.attached?
      export.destroy!
    end

    Rails.logger.info("ExportCleanupWorker: deleted #{count} data exports older than #{retention_days} days")
  end
end
