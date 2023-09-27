require 'rails_helper'

RSpec.describe WeatherService do
  describe '.get_current_weather' do
    it 'returns a hash with current weather attributes' do
      VCR.use_cassette('weatherapi_cincinnati_current_weather_service') do
        coordinates = GeocodingService.get_coordinates('cincinnati,oh')
        weather = WeatherService.get_current_weather(coordinates)

        expect(weather).to be_a(Hash)
        expect(weather[:temperature]).to be_present
      end
    end
  end

  describe '.get_daily_weather' do
    it 'returns an array of daily weather hashes' do
      VCR.use_cassette('weatherapi_cincinnati_daily_weather_service') do
        coordinates = GeocodingService.get_coordinates('cincinnati,oh')
        weather = WeatherService.get_daily_weather(coordinates)

        expect(weather).to be_an(Array)
        expect(weather.first).to be_a(Hash)
        expect(weather.first[:date]).to be_present
      end
    end
  end

  describe '.get_weather_at_eta' do
    it 'returns nil if eta is nil' do
      VCR.use_cassette('weatherapi_cincinnati_get_weather_at_eta_service') do
        coordinates = GeocodingService.get_coordinates('cincinnati,oh')
        weather = WeatherService.get_weather_at_eta(coordinates, nil)
        expect(weather).to be_nil
      end
    end
  end
end

describe '.get_hourly_weather' do
  it 'returns an array of hourly weather hashes' do
    VCR.use_cassette('weatherapi_cincinnati_hourly_weather_service') do
      coordinates = GeocodingService.get_coordinates('cincinnati,oh')
      weather = WeatherService.get_hourly_weather(coordinates)

      expect(weather).to be_an(Array)
      expect(weather.first).to be_a(Hash)
      expect(weather.first[:time]).to be_present
    end
  end
end

describe '.get_weather_at_eta' do
  it 'returns nil if eta is nil' do
    VCR.use_cassette('weatherapi_cincinnati_get_weather_at_eta_service') do
      coordinates = GeocodingService.get_coordinates('cincinnati,oh')
      weather = WeatherService.get_weather_at_eta(coordinates, nil)
      expect(weather).to be_nil
    end
  end

  it 'returns nil if no forecast is available for the given arrival date' do
    VCR.use_cassette('weatherapi_cincinnati_get_weather_at_eta_no_forecast') do
      coordinates = GeocodingService.get_coordinates('cincinnati,oh')
      # Assuming a far future eta where there's no forecast data
      eta = 15.days.to_i
      weather = WeatherService.get_weather_at_eta(coordinates, eta)
      expect(weather).to be_nil
    end
  end

  it 'returns the closest hourly forecast to the arrival time' do
    VCR.use_cassette('weatherapi_cincinnati_get_weather_at_eta_with_forecast') do
      coordinates = GeocodingService.get_coordinates('cincinnati,oh')
      eta = 2.hours.to_i
      weather = WeatherService.get_weather_at_eta(coordinates, eta)
      arrival_time = Time.now + eta.seconds

      expect(weather).to be_a(Hash)
      expect(Time.parse(weather['time'])).to be_within(1.hour).of(arrival_time)
    end
  end
end
