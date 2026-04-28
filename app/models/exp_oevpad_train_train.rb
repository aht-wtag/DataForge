class ExpOevpadTrainTrain < ApplicationRecord
  scope :active, -> { where(deleted: false) }
  scope :delta_since, ->(timestamp) { where(updated_at: timestamp..) if timestamp }
  scope :up_to_now, -> { where(updated_at: ..Time.current) }

  validates :adapter_id, presence: true, uniqueness: true
  validates :train_nr, presence: true
  validates :code_op_period, presence: true
  validates :adapter_id_timetable_period, presence: true
end
