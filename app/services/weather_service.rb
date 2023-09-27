class WeatherService
  def self.get_weather_at_eta(coordinates, eta)
    return nil unless eta

    conn = Faraday.new(url: 'http://api.weatherapi.com')
    response = conn.get("/v1/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates.latitude},#{coordinates.longitude}")
    json = JSON.parse(response.body)

    arrival_time = Time.now + eta.seconds  # Assuming eta is in seconds
    puts "Debugging current time: #{Time.now}"
    puts "Debugging arrival_time: #{arrival_time}"

    json['forecast']['forecastday'][0]['hour'].min_by do |hour|
      diff = (Time.parse(hour['time']) - arrival_time).abs
      puts "Debugging time difference: #{diff}, hour: #{hour['time']}, arrival_time: #{arrival_time}"
      diff
    end
  end
end
