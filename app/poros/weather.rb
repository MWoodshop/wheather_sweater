class Weather
  attr_reader :current_weather, :daily_weather, :hourly_weather, :weather_at_eta

  def initialize(current_weather:, daily_weather:, hourly_weather:, weather_at_eta: nil)
    @current_weather = current_weather
    @daily_weather = daily_weather
    @hourly_weather = hourly_weather
    @weather_at_eta = weather_at_eta
  end
end
