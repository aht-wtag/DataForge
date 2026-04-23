class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :lockable, :trackable, :recoverable, :rememberable

  enum role: { admin: 0, developer: 1, viewer: 2 }

  has_many :adapters, dependent: :destroy
  has_many :data_exports, dependent: :destroy

  has_secure_token :api_token

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :first_name, :last_name, presence: true
end
