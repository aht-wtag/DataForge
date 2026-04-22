class TransformationRule < ApplicationRecord
  belongs_to :endpoint

  enum target_type: { string: 0, integer: 1, float: 2, boolean: 3, datetime: 4, json: 5 }

  validates :source_path, :target_field, :target_type, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
