class Alias < ApplicationRecord
  belongs_to :user
  has_many :matched_aliases
  has_many :aliases, through: :matched_aliases, dependent: :destroy
  has_many :coordinates


  def match_aliases

  end
end
