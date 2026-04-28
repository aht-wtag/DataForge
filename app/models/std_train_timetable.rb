class StdTrainTimetable < ApplicationRecord
  belongs_to :std_train_train
  belongs_to :std_train_location
  belongs_to :std_train_timetableperiod

  scope :active, -> { where(deleted: false) }

  validates :provider_id, presence: true
  validates :sort, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
