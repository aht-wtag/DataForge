class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :lockable, :trackable, :recoverable, :rememberable

  enum role: { admin: 0, developer: 1, viewer: 2 }

  has_many :adapters, dependent: :destroy
  has_many :data_exports, dependent: :destroy

  has_secure_token :api_token

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :first_name, :last_name, presence: true
  validates_confirmation_of :password, if: :password_required?
  validate :password_complexity

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def password_complexity
    return if password.blank?

    errors.add(:password, "must contain at least one uppercase letter") unless password.match?(/[A-Z]/)
    errors.add(:password, "must contain at least one lowercase letter") unless password.match?(/[a-z]/)
    errors.add(:password, "must contain at least one digit") unless password.match?(/\d/)
  end
end
