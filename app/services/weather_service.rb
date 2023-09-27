class WeatherService
  # Get current weather
  def self.get_current_weather(coordinates)
    conn = Faraday.new(url: 'http://api.weatherapi.com')
    response = conn.get("/v1/current.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates.latitude},#{coordinates.longitude}")
    json = JSON.parse(response.body)
    {
      last_updated: json['current']['last_updated'],
      temperature: json['current']['temp_f'],
      feels_like: json['current']['feelslike_f'],
      humidity: json['current']['humidity'],
      uvi: json['current']['uv'],
      visibility: json['current']['vis_miles'],
      conditions: json['current']['condition']['text'],
      icon: json['current']['condition']['icon']
    }
  end

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

    return nil unless forecast_for_arrival

    forecast_for_arrival['hour'].min_by do |hour|
      (Time.parse(hour['time']) - arrival_time).abs
    end
  end

  # Get daily weather
  def self.get_daily_weather(coordinates)
    conn = Faraday.new(url: 'http://api.weatherapi.com')
    response = conn.get("/v1/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates.latitude},#{coordinates.longitude}")
    json = JSON.parse(response.body)
    json['forecast']['forecastday'].map do |day|
      {
        date: day['date'],
        sunrise: day['astro']['sunrise'],
        sunset: day['astro']['sunset'],
        max_temp: day['day']['maxtemp_f'],
        min_temp: day['day']['mintemp_f'],
        conditions: day['day']['condition']['text'],
        icon: day['day']['condition']['icon']
      }
    end
  end

  # Get hourly weather
  def self.get_hourly_weather(coordinates)
    conn = Faraday.new(url: 'http://api.weatherapi.com')
    response = conn.get("/v1/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates.latitude},#{coordinates.longitude}")
    json = JSON.parse(response.body)
    json['forecast']['forecastday'][0]['hour'].map do |hour|
      {
        time: hour['time'][11, 5],
        temperature: hour['temp_f'],
        conditions: hour['condition']['text'],
        icon: hour['condition']['icon']
      }
    end
  end
end
