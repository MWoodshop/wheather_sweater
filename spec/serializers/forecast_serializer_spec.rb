require 'rails_helper'

RSpec.describe ForecastSerializer do
  describe '.format' do
    it 'serializes current_weather, weather_at_eta, and coordinates into the expected format' do
      # Sample data
      current_weather = { temperature: 72.5, conditions: 'clear sky', icon: 'some_url' }
      weather_at_eta = { temperature: 75.0, conditions: 'partly cloudy', icon: 'another_url' }
      daily_weather = []
      hourly_weather = []
      coordinates = OpenStruct.new(latitude: 40.7128, longitude: -74.0060)

      # Create a new Weather object
      weather = Weather.new(
        current_weather:,
        daily_weather:,
        hourly_weather:,
        weather_at_eta:
      )

      # Call the serializer
      result = ForecastSerializer.format(weather, coordinates)

      # Verify that the serialized data is as expected
      expect(result).to eq({
                             data: {
                               id: nil,
                               type: 'forecast',
                               attributes: {
                                 current_weather:,
                                 weather_at_eta:,
                                 daily_weather:,
                                 hourly_weather:,
                                 latitude: 40.7128,
                                 longitude: -74.0060
                               }
                             }
                           })
    end
  end
end
