class DataExport < ApplicationRecord
  belongs_to :user
  belongs_to :adapter
  has_one_attached :export_file

  enum export_format: { csv: 0, json: 1, xml: 2 }
  enum status: { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :export_format, presence: true
end
