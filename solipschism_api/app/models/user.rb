class User < ApplicationRecord
  has_secure_password
  has_secure_token

  has_many :aliases

  validates :email, presence: true, uniqueness: true
  after_create :create_alias

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

  def current_alias
    aliases.where(effective_date: Date.today).pluck(:id)[0]
  end

  def alias_on_date(day)
    aliases.where(effective_date: day).pluck(:id)[0]
  end

  def create_alias
    alias_a = Alias.new(user_id: self.id, effective_date: Date.today)
    alias_a.save!
  end

  private

  # not available in has_secure_token
  def invalidate_token
    self.update_columns(token: nil)
    touch(:token_created_at)
  end
end
