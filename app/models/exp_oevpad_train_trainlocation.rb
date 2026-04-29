class ExpOevpadTrainTrainlocation < ApplicationRecord
  scope :active, -> { where(deleted: false) }
  scope :delta_since, ->(timestamp) { where(updated_at: timestamp..) if timestamp }
  scope :up_to_now, -> { where(updated_at: ..Time.current) }

  validates :adapter_id, presence: true, uniqueness: true
  validates :adapter_id_train, presence: true
  validates :adapter_id_location, presence: true
  validates :loc_abbreviation, presence: true
  validates :adapter_id_timetable_period, presence: true
  validates :type_stop, presence: true
  validates :sort, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
