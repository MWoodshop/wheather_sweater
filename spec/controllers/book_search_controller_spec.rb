require 'rails_helper'

RSpec.describe Api::V1::BookSearchController, type: :controller do
  describe 'GET #show' do
    # Happy Path
    it 'returns a valid forecast for a valid location' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co' }

        json_response = JSON.parse(response.body)
        forecast = json_response.dig('data', 'attributes', 'forecast')

        expect(forecast).to be_present
      end
    end

    it 'returns a valid book search for a valid location' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co' }

        json_response = JSON.parse(response.body)
        books = json_response.dig('data', 'attributes', 'books')

        expect(books).to be_present
      end
    end

    it 'returns books with expected fields' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co' }

        json_response = JSON.parse(response.body)
        books = json_response.dig('data', 'attributes', 'books')

        expect(books).to be_an(Array)
        expect(books.first).to include('isbn')
        expect(books.first).to include('title')
      end
    end

    it 'returns current weather with expected fields' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co' }

        json_response = JSON.parse(response.body)
        forecast = json_response.dig('data', 'attributes', 'forecast')
        expect(forecast.keys).to match_array(%w[summary temperature])
        expect(forecast['summary']).to be_a(String)
        expect(forecast['temperature']).to be_a(String)
      end
    end

    it 'returns only necessary attributes in weather and book data' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co' }

        json_response = JSON.parse(response.body)
        attributes = json_response.dig('data', 'attributes')

        expect(attributes.keys).to match_array(%w[
                                                 books destination forecast total_books_found
                                               ])

        forecast_keys = attributes['forecast'].keys
        expect(forecast_keys).to match_array(%w[summary temperature])

        books_keys = attributes['books'][0].keys
        expect(books_keys).to match_array(%w[isbn title])
      end
    end

    # Sad Path
    it 'returns an error if no location is provided' do
      VCR.use_cassette('books_weather_no_location') do
        get :show, params: { location: '' }

        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid location')
      end
    end

    it 'returns default weather and no books if invalid location is provided' do
      VCR.use_cassette('books_weather_invalid_location') do
        get :show, params: { location: 'fgjdfgdsdg' }

        json_response = JSON.parse(response.body)

        forecast = json_response.dig('data', 'attributes', 'forecast')
        books = json_response.dig('data', 'attributes', 'books')

        expect(forecast).to be_present
        expect(forecast['summary']).to be_present
        expect(forecast['summary']).to eq('Overcast')
        expect(forecast['temperature']).to be_present
        expect(forecast['temperature']).to eq('69.1 F')

        expect(books).to_not be_present
      end
    end

    # Edge Cases
    it 'returns an error for non-ASCII characters in location' do
      VCR.use_cassette('books_weather_non_ascii_location') do
        get :show, params: { location: '🤪' }

        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid location')
      end
    end
  end
end
