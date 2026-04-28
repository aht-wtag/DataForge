class ImpDilocTrain < ApplicationRecord
  self.table_name = 'imp_diloc_trains'

  validates :day, presence: true
  validates :train_nr, presence: true
  validates :sort, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :by_train_and_day, ->(train_nr, day) { where(train_nr: train_nr, day: day) }
  scope :distinct_days, -> { select(:day).distinct.order(:day) }
  scope :distinct_train_nrs, -> { select(:train_nr).distinct }

  def self.truncate!
    connection.execute("TRUNCATE TABLE #{table_name}")
  end

  def self.bulk_import!(rows, batch_size: 300)
    rows.each_slice(batch_size) do |batch|
      insert_all(batch)
    end
  end
end
