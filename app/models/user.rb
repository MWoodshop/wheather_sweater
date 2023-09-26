class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
  before_create :generate_api_key

  private

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64
  end
end
