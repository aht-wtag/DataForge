class AdapterRun < ApplicationRecord
  belongs_to :adapter

  STATES = %w[new start import transform_to_standard transform_to_export send_to_cockpit success failed].freeze
  TOTAL_STEPS = 4

  validates :name, presence: true
  validates :state, presence: true, inclusion: { in: STATES }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_adapter, ->(adapter_id) { where(adapter_id: adapter_id) }

  def self.create_for!(adapter, name:)
    create!(
      adapter: adapter,
      name: name,
      state: 'new',
      progress: 0
    )
  end

  def set_state!(new_state)
    update!(state: new_state)
  end

  def set_progress!(step)
    update!(progress: (100.0 * step / TOTAL_STEPS).round)
  end

  def set_result!(data)
    update!(result: data)
  end

  def mark_ended!
    update!(ended_at: Time.current)
  end

  def mark_failed!(error:)
    update!(
      state: 'failed',
      error: error.is_a?(Exception) ? error.message : error.to_s,
      stack: error.is_a?(Exception) ? error.backtrace&.first(20)&.join("\n") : nil,
      ended_at: Time.current
    )
  end

  def duration
    return nil unless ended_at && created_at
    ended_at - created_at
  end
end
