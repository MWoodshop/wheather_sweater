require 'cgi'
require 'net/http'
require 'json'

module Api
  module V1
    class BookSearchController < ApplicationController
      def show
        location = params[:location]
        quantity = params[:quantity].to_i

        coordinates = get_coordinates(location)
        if coordinates
          weather_data = get_weather(coordinates)
          books = get_books(location, quantity)

          render json: {
            data: {
              id: 'null',
              type: 'books',
              attributes: {
                destination: location,
                forecast: {
                  summary: weather_data[:conditions],
                  temperature: "#{weather_data[:temperature]} F"
                },
                total_books_found: books[:total],
                books: books[:list]
              }
            }
          }
        else
          render json: { error: 'Invalid location' }, status: 400
        end
      end

      private

      def get_books(location, quantity)
        conn = Faraday.new(url: 'https://openlibrary.org')
        response = conn.get("/search.json?q=#{CGI.escape(location)}")
        json = JSON.parse(response.body)

        books = []
        json['docs'].first(quantity).each do |doc|
          books << {
            isbn: doc['isbn'],
            title: doc['title'],
            publisher: doc['publisher']
          }
        end

        { total: json['num_found'], list: books }
      end

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
          last_updated: json['current']['last_updated'],
          temperature: json['current']['temp_f'],
          feels_like: json['current']['feelslike_f'],
          humidity: json['current']['humidity'],
          uvi: json['current']['uv'],
          visibility: json['current']['vis_miles'],
          conditions: json['current']['condition']['text'],
          icon: json['current']['condition']['icon']
        }

        daily_weather = json['forecast']['forecastday'].map do |day|
          {
            date: day['date'],
            sunrise: day['astro']['sunrise'],
            sunset: day['astro']['sunset'],
            max_temp: day['day']['maxtemp_f'],
            min_temp: day['day']['mintemp_f'],
            conditions: day['day']['condition']['text'],
            icon: day['day']['condition']['icon']
          }
        end

        hourly_weather = json['forecast']['forecastday'][0]['hour'].map do |hour|
          {
            time: hour['time'][11, 5],
            temperature: hour['temp_f'],
            conditions: hour['condition']['text'],
            icon: hour['condition']['icon']
          }
        end

        {
          current_weather:,
          daily_weather:,
          hourly_weather:,
          latitude: coordinates[:latitude],
          longitude: coordinates[:longitude]
        }
      end
    end
  end
end
