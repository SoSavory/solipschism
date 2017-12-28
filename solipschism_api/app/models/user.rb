class User < ApplicationRecord
  has_secure_password
  has_secure_token

  has_one :coordinate
  has_many :matched_users
  has_many :users, through: :matched_users, dependent: :destroy

  has_many :articles

  validates :email, presence: true, uniqueness: true

  def self.valid_login?(email, password)
    user = find_by(email: email)
    if user && user.authenticate(password)
      user
    end
  end

  def allow_token_to_be_used_only_once
    regenerate_token
    touch(:token_created_at)
  end

  def logout
    invalidate_token
  end

  def self.with_unexpired_token(token, period)
    where(token: token).where('token_created_at >= ?', period).first
  end

  private

  # not available in has_secure_token
  def invalidate_token
    self.update_columns(token: nil)
    touch(:token_created_at)
  end
end
