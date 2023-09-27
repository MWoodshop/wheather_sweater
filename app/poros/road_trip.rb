class RoadTrip
  attr_reader :origin, :destination, :travel_info, :weather_info

  def initialize(origin:, destination:, travel_info:, weather_info:)
    @origin = origin
    @destination = destination
    @travel_info = travel_info
    @weather_info = weather_info
  end
end
