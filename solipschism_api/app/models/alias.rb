class Alias < ApplicationRecord
  belongs_to :user
  has_many :matched_aliases

end
