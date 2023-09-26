require 'rails_helper'

RSpec.describe WeatherService do
  describe '.get_weather' do
    it 'returns a Weather object with current, daily, and hourly weather' do
      VCR.use_cassette('weatherapi_cincinnati_weather_service') do
        coordinates = GeocodingService.get_coordinates('cincinnati,oh')
        weather = WeatherService.get_weather(coordinates)

        expect(weather).to be_a(Weather)

        expect(weather.current_weather).to be_present

        expect(weather.daily_weather).to be_present
        expect(weather.daily_weather.count).to be > 0
        expect(weather.daily_weather.first).to be_present

        expect(weather.hourly_weather).to be_present
        expect(weather.hourly_weather.count).to be > 0
        expect(weather.hourly_weather.first).to be_present
      end
    end
  end
end
