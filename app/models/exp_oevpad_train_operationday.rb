class ExpOevpadTrainOperationday < ApplicationRecord
  scope :active, -> { where(deleted: false) }
  scope :delta_since, ->(timestamp) { where(updated_at: timestamp..) if timestamp }
  scope :up_to_now, -> { where(updated_at: ..Time.current) }

  validates :adapter_id, presence: true
  validates :date, presence: true, uniqueness: true
  validates :code_op_period, presence: true
  validates :period_key, presence: true
  validates :adapter_id_timetable_period, presence: true
end
