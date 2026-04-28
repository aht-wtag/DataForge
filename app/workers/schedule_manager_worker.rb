class ScheduleManagerWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default", retry: 3

  def perform
    JobSchedule.where(enabled: true).where("next_run_at <= ?", Time.current).find_each do |schedule|
      ExecutionWorker.perform_async(schedule.adapter_id, schedule.endpoint_id, schedule.id)
      schedule.update!(last_run_at: Time.current)
    end
  end
end
