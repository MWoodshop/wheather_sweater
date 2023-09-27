require 'rails_helper'

RSpec.describe Api::V0::RoadTripsController, type: :controller do
  before do
    @user = FactoryBot.create(:user)
  end

  describe 'POST #create', :vcr do
    let(:params) do
      {
        origin: 'New York, NY',
        destination: 'Los Angeles, CA',
        api_key: @user.api_key
      }
    end

    it 'returns 200 when road trip is successfully created' do
      VCR.use_cassette('road_trip_success') do
        post(:create, params:)
      end
      expect(response).to have_http_status(:ok)
    end

    it 'returns 402 when route is impossible' do
      allow(GeocodingService).to receive(:fetch_directions).and_return({
                                                                         'route' => {
                                                                           'routeError' => {
                                                                             'errorCode' => 2
                                                                           }
                                                                         }
                                                                       })

      post(:create, params:)
      expect(response).to have_http_status(402)
    end

    it 'returns 400 when destination is invalid' do
      allow(GeocodingService).to receive(:fetch_directions).and_return({
                                                                         'route' => {
                                                                           'time' => 3600
                                                                         }
                                                                       })
      allow(GeocodingService).to receive(:get_coordinates).and_return(nil)

      post :create, params: params.merge(destination: 'Invalid Destination')
      expect(response).to have_http_status(400)
    end

    it 'returns 401 when invalid API key is provided' do
      VCR.use_cassette('road_trip_invalid_api_key') do
        post(:create, params: params.merge(api_key: 'invalid_key'))
      end
      expect(response).to have_http_status(401)
    end
    it 'returns 500 when required info could not be fetched' do
      allow(GeocodingService).to receive(:fetch_directions).and_return({
                                                                         'route' => {
                                                                           'time' => nil
                                                                         }
                                                                       })
      allow(GeocodingService).to receive(:get_coordinates).and_return({
                                                                        'lat' => 40.7128,
                                                                        'lng' => -74.0060
                                                                      })
      allow(WeatherService).to receive(:get_weather_at_eta).and_return(nil)

      post(:create, params:)
      expect(response).to have_http_status(500)
    end
  end
end
