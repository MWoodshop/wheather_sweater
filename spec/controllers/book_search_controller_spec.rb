require 'rails_helper'

RSpec.describe Api::V1::BookSearchController, type: :controller do
  describe 'GET #show' do
    # Happy Path
    it 'returns a valid forecast for a valid location and quantity' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co', quantity: 5 }

        json_response = JSON.parse(response.body)
        forecast = json_response.dig('data', 'attributes', 'forecast')

        expect(forecast).to be_present
      end
    end

    it 'returns a valid book search for a valid location and quantity' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co', quantity: 5 }

        json_response = JSON.parse(response.body)
        books = json_response.dig('data', 'attributes', 'books')

        expect(books).to be_present
      end
    end

    it 'returns books with expected fields' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co', quantity: 5 }

        json_response = JSON.parse(response.body)
        books = json_response.dig('data', 'attributes', 'books')

        expect(books).to be_an(Array)
        expect(books.first).to include('isbn')
        expect(books.first).to include('title')
      end
    end

    it 'returns current weather with expected fields' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co', quantity: 5 }

        json_response = JSON.parse(response.body)
        forecast = json_response.dig('data', 'attributes', 'forecast')
        expect(forecast.keys).to match_array(%w[summary temperature])
        expect(forecast['summary']).to be_a(String)
        expect(forecast['temperature']).to be_a(String)
      end
    end

    it 'returns the correct number of books based on search parameters' do
      VCR.use_cassette('books_weather_denver_30') do
        get :show, params: { location: 'denver,co', quantity: 30 }

        json_response = JSON.parse(response.body)
        total_books_found = json_response.dig('data', 'attributes', 'total_books_found')
        expect(total_books_found).to eq(30)
      end
    end

    it 'returns only necessary attributes in weather and book data' do
      VCR.use_cassette('books_weather_denver') do
        get :show, params: { location: 'denver,co', quantity: 5 }

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
        get :show, params: { location: '', quantity: 5 }

        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid location')
      end
    end

    it 'returns default weather and no books if invalid location is provided' do
      VCR.use_cassette('books_weather_invalid_location') do
        get :show, params: { location: 'fgjdfgdsdg', quantity: 5 }

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

    it 'returns default weather and no books if no quantity is provided' do
      VCR.use_cassette('books_weather_denver_no_quantity') do
        get :show, params: { location: 'denver,co' }
        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Invalid quantity')
      end
    end

    it 'returns a 500 error if there is a network error' do
      allow(Faraday).to receive(:new).and_return(
        instance_double(Faraday::Connection).tap do |faraday|
          allow(faraday).to receive(:get).and_raise(Faraday::ConnectionFailed, nil)
        end
      )

      get :show, params: { location: 'denver,co', quantity: 5 }

      expect(response.status).to eq(500)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Service Unavailable')
    end
  end

  # Edge Cases
  it 'returns an error for non-ASCII characters in location' do
    VCR.use_cassette('books_weather_non_ascii_location') do
      get :show, params: { location: '🤪', quantity: 5 }

      expect(response.status).to eq(400)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Invalid location')
    end
  end

  it 'returns an error for a quantity of 0' do
    VCR.use_cassette('books_weather_denver_0_quantity') do
      get :show, params: { location: 'denver,co', quantity: 0 }
      expect(response.status).to eq(400)
      json_response = JSON.parse(response.body)

      expect(json_response['error']).to eq('Invalid quantity')
    end
  end

  it 'returns an error for a quantity of a negative number' do
    VCR.use_cassette('books_weather_denver_negative_quantity') do
      get :show, params: { location: 'denver,co', quantity: -100 }
      expect(response.status).to eq(400)
      json_response = JSON.parse(response.body)

      expect(json_response['error']).to eq('Invalid quantity')
    end
  end

  it 'returns an error for a quantity of non-ASCII character' do
    VCR.use_cassette('books_weather_denver_negative_quantity') do
      get :show, params: { location: 'denver,co', quantity: '¶' }
      expect(response.status).to eq(400)
      json_response = JSON.parse(response.body)

      expect(json_response['error']).to eq('Invalid quantity')
    end
  end
end
