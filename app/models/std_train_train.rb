class StdTrainTrain < ApplicationRecord
  belongs_to :std_train_operationperiod
  belongs_to :std_train_timetableperiod
  has_many :std_train_timetables, dependent: :destroy

  scope :active, -> { where(deleted: false) }

  validates :train_nr, presence: true
  validates :train_nr, uniqueness: { scope: :std_train_operationperiod_id }
end
