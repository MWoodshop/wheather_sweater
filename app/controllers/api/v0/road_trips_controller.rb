module Api
  module V0
    class RoadTripsController < ApplicationController
      before_action :authenticate

      def create
        origin = params[:origin]
        destination = params[:destination]

        travel_info = GeocodingService.fetch_directions(origin, destination)
        puts "Debugging travel_info: #{travel_info.inspect}"

        if travel_info.dig('route', 'routeError', 'errorCode') == 2
          render json: { error: 'Impossible route' }, status: 402
          return
        end

        eta = travel_info['route']['time']
        puts "Debugging eta: #{eta.inspect}"

        coordinates = GeocodingService.get_coordinates(destination)
        puts "Debugging coordinates: #{coordinates.inspect}"

        if coordinates.nil?
          render json: { error: 'Invalid destination' }, status: 400
          return
        end

        weather_info = WeatherService.get_weather_at_eta(coordinates, eta)
        puts "Debugging weather_info: #{weather_info.inspect}"

        if eta.nil? || weather_info.nil?
          render json: { error: 'Failed to fetch some required info' }, status: 500
          return
        end

        road_trip = RoadTrip.new(
          origin:,
          destination:,
          travel_info:,
          weather_info:
        )

        render json: RoadTripSerializer.format(road_trip)

        puts "Debugging road_trip: #{road_trip.inspect}"
      end

      private

      def authenticate
        api_key = params[:api_key]
        render json: { error: 'Invalid API key' }, status: 401 unless User.exists?(api_key:)
      end
    end
  end
end
