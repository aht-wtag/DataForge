class Adapter < ApplicationRecord
  belongs_to :user
  has_many :endpoints, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :job_schedules, dependent: :destroy
  has_many :execution_logs, dependent: :destroy
  has_many :stored_data, dependent: :destroy
  has_many :adapter_runs, dependent: :destroy
  has_one_attached :logo

  enum status: { active: 0, running: 1, error: 2, disabled: 3 }
  enum adapter_type: { generic: 0, diloc: 1 }

  ADAPTER_TYPES = %w[generic diloc].freeze

  DILOC_REQUIRED_CONFIG_KEYS = {
    "DiLocBaseurl" => "DiLoc Base URL",
    "apiKey" => "API Key",
    "oevpadCockpiturl" => "OeVPAD Cockpit URL",
    "CockpitApiKey" => "Cockpit API Key"
  }.freeze

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  validates :name, :base_url, :adapter_type, presence: true
  validates :adapter_type, inclusion: { in: ADAPTER_TYPES }
  validates :base_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :rate_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :timeout, numericality: { greater_than: 0, less_than_or_equal_to: 300 }, allow_nil: true
  validate :validate_diloc_config, if: -> { diloc? }

  store_accessor :config, :DiLocBaseurl, :apiKey, :oevpadCockpiturl, :CockpitApiKey,
                 :startDateTime, :endDateTime, :offsetHours,
                 :oevpadCockpiturlSslRejectUnauthorized, prefix: false

  def adapter_config
    config.with_indifferent_access
  end

  def adapter_type_label
    adapter_type.humanize
  end

  def diloc_config_complete?
    DILOC_REQUIRED_CONFIG_KEYS.keys.all? { |k| config[k].present? }
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end

  private

  def validate_diloc_config
    DILOC_REQUIRED_CONFIG_KEYS.each do |key, label|
      next if config[key].present?

      errors.add(:base, "#{label} is required for DiLoc adapter type")
    end
  end
end
