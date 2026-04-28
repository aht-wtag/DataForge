class ExpOevpadTrainTimetableperiod < ApplicationRecord
  scope :active, -> { where(deleted: false) }
  scope :delta_since, ->(timestamp) { where(updated_at: timestamp..) if timestamp }
  scope :up_to_now, -> { where(updated_at: ..Time.current) }

  validates :adapter_id, presence: true, uniqueness: true
  validates :date_period_start, presence: true
  validates :date_period_end, presence: true
end
