class Alias < ApplicationRecord
  belongs_to :user
  has_many :matched_aliases
  has_many :aliases, through: :matched_aliases, dependent: :destroy
  has_one :coordinate

  after_create :create_coordinates

  has_many :articles

  def create_coordinates
    Coordinate.create(alias_id: self.id, latitude: 0, longitude: 0)
  end

end
