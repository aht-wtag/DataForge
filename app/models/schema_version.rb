class SchemaVersion < ApplicationRecord
  scope :successful, -> { where(success: 1) }
  scope :failed, -> { where(success: 0) }

  def success?
    success == 1
  end
end
