require 'rails_helper'

RSpec.describe Api::V0::ForecastsController, type: :controller do
  describe 'GET #show' do
    context 'with a valid location' do
      it 'returns a 200 OK status and serialized weather data' do
        VCR.use_cassette('mapquest_and_weatherapi_cincinnati_controller') do
          get :show, params: { location: 'cincinnati,oh' }

          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response[:data][:attributes]).to include(
            :current_weather,
            :daily_weather,
            :hourly_weather,
            :latitude,
            :longitude
          )
        end
      end
    end

    context 'with an invalid location' do
      it 'returns the defaults' do
        VCR.use_cassette('mapquest_invalid_location_controller') do
          get :show, params: { location: 'invalid_location' }

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response[:data][:attributes][:latitude]).to eq(38.89037)
          expect(json_response[:data][:attributes][:longitude]).to eq(-77.03196)
        end
      end
    end

    context 'with a blank location' do
      it 'returns a 400 Bad Request status and an error message' do
        VCR.use_cassette('mapquest_missing_location_controller') do
          get :show, params: { location: '' }

          expect(response).to have_http_status(:bad_request)

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response).to include(
            error: 'Invalid location'
          )
        end
      end
    end
  end
end
