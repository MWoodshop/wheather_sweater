class WeatherService
  def self.get_weather(coordinates)
    conn = Faraday.new(url: 'http://api.weatherapi.com')
    response = conn.get("/v1/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates.latitude},#{coordinates.longitude}")
    json = JSON.parse(response.body)

    current_weather = {
      last_updated: json['current']['last_updated'],
      temperature: json['current']['temp_f'],
      feels_like: json['current']['feelslike_f'],
      humidity: json['current']['humidity'],
      uvi: json['current']['uv'],
      visibility: json['current']['vis_miles'],
      conditions: json['current']['condition']['text'],
      icon: json['current']['condition']['icon']
    }

    daily_weather = json['forecast']['forecastday'].map do |day|
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

    hourly_weather = json['forecast']['forecastday'][0]['hour'].map do |hour|
      {
        time: hour['time'][11, 5],
        temperature: hour['temp_f'],
        conditions: hour['condition']['text'],
        icon: hour['condition']['icon']
      }
    end

    Weather.new(
      current_weather:,
      daily_weather:,
      hourly_weather:
    )
  end
end
