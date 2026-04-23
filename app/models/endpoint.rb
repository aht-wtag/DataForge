class Endpoint < ApplicationRecord
  belongs_to :adapter
  has_many :transformation_rules, -> { order(position: :asc) }, dependent: :destroy
  has_many :execution_logs, dependent: :destroy
  has_many :stored_data, dependent: :destroy

  enum http_method: { get: 0, post: 1, put: 2, patch: 3, delete: 4 }, _prefix: true

  validates :http_method, :path, :name, presence: true
  validates :path, format: { with: %r{\A/} }
end
