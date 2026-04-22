class StoredDatum < ApplicationRecord
  belongs_to :adapter
  belongs_to :endpoint
  belongs_to :execution_log, optional: true

  validates :data, presence: true

  before_create :set_record_hash

  scope :by_adapter, ->(adapter_id) { where(adapter_id: adapter_id) }
  scope :by_endpoint, ->(endpoint_id) { where(endpoint_id: endpoint_id) }

  private

  def set_record_hash
    self.record_hash = Digest::SHA256.hexdigest(data.to_json)
  end
end
