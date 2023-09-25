require 'rails_helper'

RSpec.describe Api::V0::ForecastsController, type: :controller do
  describe 'GET #show' do
    # Happy Path
    it 'returns correct latitude and longitude from MapQuest API' do
      VCR.use_cassette('mapquest_cincinnati') do
        get :show, params: { location: 'cincinnati,oh' }

        json_response = JSON.parse(response.body)
        coordinates = json_response.dig('data', 'attributes', 'latitude') &&
                      json_response.dig('data', 'attributes', 'longitude')

        expect(coordinates).to be_present
      end
    end

    it 'returns only necessary attributes in weather data' do
      VCR.use_cassette('weatherapi_cincinnati') do
        get :show, params: { location: 'cincinnati,oh' }

        json_response = JSON.parse(response.body)
        attributes = json_response.dig('data', 'attributes')

        expect(attributes.keys).to match_array(%w[
                                                 current_weather daily_weather hourly_weather latitude longitude
                                               ])

        current_weather_keys = attributes['current_weather'].keys
        expect(current_weather_keys).to match_array(%w[
                                                      last_updated temperature feels_like humidity
                                                      uvi visibility conditions icon
                                                    ])

        daily_weather_keys = attributes['daily_weather'][0].keys
        expect(daily_weather_keys).to match_array(%w[
                                                    date sunrise sunset max_temp min_temp conditions icon
                                                  ])

        hourly_weather_keys = attributes['hourly_weather'][0].keys
        expect(hourly_weather_keys).to match_array(%w[
                                                     time temperature conditions icon
                                                   ])
      end
    end

    it 'returns the current weather for a specific location' do
      VCR.use_cassette('weatherapi_cincinnati_current_weather') do
        get :show, params: { location: 'cincinnati,oh' }

        json_response = JSON.parse(response.body)
        current_weather = json_response.dig('data', 'attributes', 'current_weather')

        expect(current_weather['last_updated']).to eq('2023-09-24 15:30')
        expect(current_weather['temperature']).to eq(80.1)
        expect(current_weather['feels_like']).to eq(80.8)
        expect(current_weather['humidity']).to eq(45)
        expect(current_weather['uvi']).to eq(7.0)
        expect(current_weather['visibility']).to eq(9.0)
        expect(current_weather['conditions']).to eq('Sunny')
        expect(current_weather['icon']).to eq('//cdn.weatherapi.com/weather/64x64/day/113.png')
      end
    end

    it 'returns the daily weather for a specific location' do
      VCR.use_cassette('weatherapi_cincinnati_daily_weather') do
        get :show, params: { location: 'cincinnati,oh' }

        json_response = JSON.parse(response.body)
        daily_weather = json_response.dig('data', 'attributes', 'daily_weather')

        expect(daily_weather[0]['date']).to eq('2023-09-24')
        expect(daily_weather[0]['sunrise']).to eq('07:27 AM')
        expect(daily_weather[0]['sunset']).to eq('07:32 PM')
        expect(daily_weather[0]['max_temp']).to eq(83.5)
        expect(daily_weather[0]['min_temp']).to eq(57.0)
        expect(daily_weather[0]['conditions']).to eq('Sunny')
        expect(daily_weather[0]['icon']).to eq('//cdn.weatherapi.com/weather/64x64/day/113.png')
      end
    end

    it 'returns the hourly weather for a specific location' do
      VCR.use_cassette('weatherapi_cincinnati_hourly_weather') do
        get :show, params: { location: 'cincinnati,oh' }

        json_response = JSON.parse(response.body)
        hourly_weather = json_response.dig('data', 'attributes', 'hourly_weather')

        expect(hourly_weather[0]['time']).to eq('00:00')
        expect(hourly_weather[0]['temperature']).to eq(63.7)
        expect(hourly_weather[0]['conditions']).to eq('Clear')
        expect(hourly_weather[0]['icon']).to eq('//cdn.weatherapi.com/weather/64x64/night/113.png')
      end
    end

    # Sad Path
    it 'returns an error if no location is provided' do
      VCR.use_cassette('mapquest_no_location') do
        get :show, params: { location: '' }

        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid location')
      end
    end

    it 'handles invalid location from MapQuest API' do
      VCR.use_cassette('mapquest_invalid_location') do
        get :show, params: { location: 'aaaaaa' }
        json_response = JSON.parse(response.body)

        latitude = json_response.dig('data', 'attributes', 'latitude')
        longitude = json_response.dig('data', 'attributes', 'longitude')

        expect(latitude).to be_present
        expect(longitude).to be_present
        expect(latitude).to eq(38.89037)
        expect(longitude).to eq(-77.03196)
      end
    end
  end
end
