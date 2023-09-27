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

    context 'when given two locations' do
      it 'fetches directions' do
        VCR.use_cassette('mapquest_cincinnati_to_denver_directions') do
          directions = GeocodingService.fetch_directions('cincinnati,oh', 'denver,co')

          expect(directions).to be_a(Hash)
          expect(directions).to have_key('route')
          expect(directions['route']).to have_key('distance')
          expect(directions['route']).to have_key('formattedTime')
          expect(directions['route']).to have_key('legs')
          expect(directions['route']['legs'].first).to have_key('maneuvers')
          expect(directions['route']['legs'].first['maneuvers'].first).to have_key('narrative')
        end
      end
    end
  end
end
