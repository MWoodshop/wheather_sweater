require 'rails_helper'

RSpec.describe GeocodingService do
  describe '.get_coordinates' do
    context 'when given a valid location' do
      it 'returns a Coordinates object with latitude and longitude' do
        VCR.use_cassette('mapquest_cincinnati_geocoding_service') do
          coordinates = GeocodingService.get_coordinates('cincinnati,oh')

          expect(coordinates).to be_a(Coordinates)
          expect(coordinates.latitude).to be_present
          expect(coordinates.longitude).to be_present
        end
      end
    end

    context 'when given an invalid location' do
      it 'returns default coordinates' do
        VCR.use_cassette('mapquest_invalid_location_geocoding_service') do
          coordinates = GeocodingService.get_coordinates('invalid_location')

          expect(coordinates.latitude).to eq(38.89037)
          expect(coordinates.longitude).to eq(-77.03196)
        end
      end
    end
  end
end
