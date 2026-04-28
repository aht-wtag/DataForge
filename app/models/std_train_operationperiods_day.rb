class StdTrainOperationperiodsDay < ApplicationRecord
  belongs_to :std_train_operationperiod

  validates :std_train_operationperiod_id, uniqueness: { scope: :date }
end
