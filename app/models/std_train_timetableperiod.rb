class StdTrainTimetableperiod < ApplicationRecord
  has_many :std_train_trains, dependent: :destroy
  has_many :std_train_timetables, dependent: :destroy

  scope :active, -> { where(deleted: false) }

  validates :date_period_start, presence: true
  validates :date_period_end, presence: true

  def self.default_period
    active.find_by(
      "date_period_start <= ? AND date_period_end >= ?",
      Date.current, Date.current
    )
  end
end
