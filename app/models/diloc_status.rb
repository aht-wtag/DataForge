class DilocStatus < ApplicationRecord
  enum state: { failure: 0, success: 1 }

  validates :id, inclusion: { in: [1], message: 'only a single status row is allowed' }

  def self.instance
    find_or_create_by!(id: 1) do |s|
      s.state = :failure
    end
  end

  def mark_success!
    update!(state: :success, last_synced: Time.current)
  end

  def mark_failure!
    update!(state: :failure)
  end
end
