class ExecutionLog < ApplicationRecord
  belongs_to :adapter
  belongs_to :endpoint, optional: true
  belongs_to :job_schedule, optional: true
  has_many :stored_data, dependent: :nullify

  enum status: { pending: 0, running: 1, completed: 2, failed: 3, partial: 4 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(s) { where(status: s) }
  scope :in_time_range, ->(from, to) { where(created_at: from..to) }

  def duration
    return nil unless started_at && finished_at
    finished_at - started_at
  end

  def success_rate
    return 0 if records_extracted.to_i.zero?
    ((records_loaded.to_f / records_extracted) * 100).round(2)
  end
end
