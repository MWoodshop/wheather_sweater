class RoadTripSerializer
  def self.format(road_trip)
    {
      data: {
        type: 'road_trip',
        attributes: {
          start_city: road_trip.origin,
          end_city: road_trip.destination,
          travel_time: road_trip.travel_info.dig('route', 'formattedTime'),
          weather_at_eta: {
            datetime: road_trip.weather_info['time'], # Check if this exists in the road_trip object
            temperature: road_trip.weather_info['temp_f'], # Check if this exists in the road_trip object
            condition: road_trip.weather_info.dig('condition', 'text') # Check if this exists in the road_trip object
          }
        }
      }
    }
  end
end
