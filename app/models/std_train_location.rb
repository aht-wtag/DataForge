class StdTrainLocation < ApplicationRecord
  has_many :std_train_timetables, dependent: :destroy

  scope :active, -> { where(deleted: false) }

  validates :abbreviation, presence: true
  validates :name, presence: true
  validates :provider_id, presence: true, uniqueness: true
end
