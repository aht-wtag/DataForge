class StdTrainOperationperiod < ApplicationRecord
  has_many :std_train_operationperiods_days, dependent: :destroy
  has_many :std_train_trains, dependent: :destroy

  scope :active, -> { where(deleted: false) }

  validates :code, presence: true, uniqueness: true
end
