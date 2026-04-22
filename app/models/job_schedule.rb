class JobSchedule < ApplicationRecord
  belongs_to :adapter
  belongs_to :endpoint

  validates :cron_expression, :timezone, presence: true
  validate :valid_cron_expression?

  after_save :calculate_next_run

  def human_readable_schedule
    fugit = Fugit.parse_cron(cron_expression)
    fugit.to_s
  end

  private

  def valid_cron_expression?
    parsed = Fugit.parse_cron(cron_expression)
    errors.add(:cron_expression, "is not a valid cron expression") if parsed.nil?
  end

  def calculate_next_run
    fugit = Fugit.parse_cron(cron_expression)
    next_time = fugit.next_time.to_local_timezone(Time.find_zone(timezone))
    update_column(:next_run_at, next_time)
  end
end
