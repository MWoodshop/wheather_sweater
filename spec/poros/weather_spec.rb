require 'rails_helper'

RSpec.describe Weather do
  describe '#initialize' do
    it 'initializes with current_weather, daily_weather, and hourly_weather' do
      weather = Weather.new(current_weather: 'current_weather', daily_weather: 'daily_weather',
                            hourly_weather: 'hourly_weather')

      expect(weather.current_weather).to eq('current_weather')
      expect(weather.daily_weather).to eq('daily_weather')
      expect(weather.hourly_weather).to eq('hourly_weather')
    end
  end
end
