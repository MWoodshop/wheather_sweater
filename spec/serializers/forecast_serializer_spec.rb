require 'rails_helper'

RSpec.describe ForecastSerializer do
  describe '.format' do
    it 'serializes a Weather object and coordinates into the expected format' do
      # Sample data
      current_weather = { temperature: 72.5, conditions: 'clear sky', icon: 'some_url' }
      daily_weather = [{ date: '2023-09-26', max_temp: 72.5 }]
      hourly_weather = [{ time: '12:00', temperature: 72.5 }]
      coordinates = OpenStruct.new(latitude: 40.7128, longitude: -74.0060)

      weather = Weather.new(
        current_weather:,
        daily_weather:,
        hourly_weather:
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
