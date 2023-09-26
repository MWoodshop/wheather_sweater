require 'rails_helper'

RSpec.describe Coordinates do
  describe '#initialize' do
    it 'initializes with latitude and longitude' do
      coordinates = Coordinates.new(latitude: 40.7128, longitude: -74.0060)

      expect(coordinates.latitude).to eq(40.7128)
      expect(coordinates.longitude).to eq(-74.0060)
    end
  end
end
