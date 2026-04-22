class Adapter < ApplicationRecord
  belongs_to :user
  has_many :endpoints, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :job_schedules, dependent: :destroy
  has_many :execution_logs, dependent: :destroy
  has_many :stored_data, dependent: :destroy
  has_one_attached :logo

  enum status: { active: 0, running: 1, error: 2, disabled: 3 }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  validates :name, :base_url, presence: true
  validates :base_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :rate_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :timeout, numericality: { greater_than: 0, less_than_or_equal_to: 300 }, allow_nil: true

  def archive!
    update!(archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end
end
