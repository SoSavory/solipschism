class Coordinate < ApplicationRecord
  belongs_to :user

  def self.compare_coordinates(lat1, lat2, long1, long2)
    # Lambda is longitude, omega is latitude
    # Takes latitudes and longitudes in radians, returns distance in meters
    x = (long1 - long2)*Math.cos((lat1 + lat2)/2)
    y = lat1 - lat2
    return ((x*x) + (y*y)) * (4.0589641e+13)
  end
end
