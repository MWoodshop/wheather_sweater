module Api
  module V0
    class ForecastsController < ApplicationController
      def show
        location = params[:location]
        coordinates = GeocodingService.get_coordinates(location)

        if coordinates
          weather = WeatherService.get_weather(coordinates)
          render json: ForecastSerializer.format(weather, coordinates)
        else
          render json: { error: 'Invalid location' }, status: 400
        end
      end
    end
  end
end
