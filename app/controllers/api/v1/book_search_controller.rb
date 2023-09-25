module Api
  module V1
    class BookSearchController < ApplicationController
      def show
        location = params[:location]
        coordinates = get_coordinates(location)

        if coordinates
          weather_data = get_weather(coordinates)
          book_data = get_books(location)

          render json: {
            data: {
              id: nil,
              type: 'books',
              attributes: {
                destination: location,
                forecast: weather_data[:current_weather],
                total_books_found: book_data.length,
                books: book_data
              }
            }
          }
        else
          render json: { error: 'Invalid location' }, status: 400
        end
      end

      private

      def get_coordinates(location)
        conn = Faraday.new(url: 'http://www.mapquestapi.com')
        response = conn.get("/geocoding/v1/address?key=#{ENV['MAPQUEST_API_KEY']}&location=#{location}")
        json = JSON.parse(response.body)

        latitude = json.dig('results', 0, 'locations', 0, 'latLng', 'lat')
        longitude = json.dig('results', 0, 'locations', 0, 'latLng', 'lng')

        latitude && longitude ? { latitude:, longitude: } : nil
      end

      def get_weather(coordinates)
        conn = Faraday.new(url: 'http://api.weatherapi.com')
        response = conn.get("/v1/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{coordinates[:latitude]},#{coordinates[:longitude]}")
        json = JSON.parse(response.body)

        current_weather = {
          summary: json['current']['condition']['text'],
          temperature: "#{json['current']['temp_f']} F"
        }

        {
          current_weather:
        }
      end

      def get_books(location)
        conn = Faraday.new(url: 'https://openlibrary.org')
        all_books = []
        offset = 0
        limit = 100

        loop do
          response = conn.get("/search.json?q=#{location}&offset=#{offset}&limit=#{limit}")
          json = JSON.parse(response.body)

          break if json['docs'].empty?

          all_books += json['docs'].map do |doc|
            {
              isbn: doc['isbn'],
              title: doc['title']
            }
          end

          offset += limit
        end

        all_books
      end
    end
  end
end
