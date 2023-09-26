class Coordinates
  attr_reader :latitude, :longitude

  def initialize(latitude:, longitude:)
    @latitude = latitude
    @longitude = longitude
  end
end
