class ForecastSerializer
  def self.format(weather, coordinates)
    {
      data: {
        id: nil,
        type: 'forecast',
        attributes: {
          current_weather: weather.current_weather,
          daily_weather: weather.daily_weather,
          hourly_weather: weather.hourly_weather,
          weather_at_eta: weather.weather_at_eta,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude
        }
      }
    }
  end
end
