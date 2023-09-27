class WeatherService
  def self.get_weather_at_eta(coordinates, eta)
    return nil unless eta

    conn = Faraday.new(url: 'http://api.weatherapi.com')
    response = conn.get("/v1/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates.latitude},#{coordinates.longitude}&days=14")
    json = JSON.parse(response.body)

    arrival_time = Time.now + eta.seconds
    arrival_date_str = arrival_time.strftime('%Y-%m-%d')

    forecast_for_arrival = json['forecast']['forecastday'].find do |forecastday|
      forecastday['date'] == arrival_date_str
    end

    return unless forecast_for_arrival

    forecast_for_arrival['hour'].min_by do |hour|
      (Time.parse(hour['time']) - arrival_time).abs
    end

    # Return closest hour to the RoadTripsController
  end
end
