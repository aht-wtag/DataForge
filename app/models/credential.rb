class Credential < ApplicationRecord
  belongs_to :adapter

  enum credential_type: { bearer_token: 0, api_key: 1, basic_auth: 2, custom_header: 3 }

  encrypts :value, column: "encrypted_value"

  validates :name, :credential_type, presence: true
  validates :value, presence: true

  def masked_value
    return nil unless value.present?
    length = value.length
    return "****" if length <= 4
    "#{value[0..1]}#{"*" * (length - 4)}#{value[-2..]}"
  end
end
