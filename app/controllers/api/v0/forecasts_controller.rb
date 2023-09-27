module Api
  module V0
    class ForecastsController < ApplicationController
      def show
        location = params[:location]
        coordinates = GeocodingService.get_coordinates(location)

        if coordinates
          eta = params[:eta]
          weather_at_eta = eta ? WeatherService.get_weather_at_eta(coordinates, eta.to_i) : nil
          current_weather = WeatherService.get_current_weather(coordinates)
          daily_weather = WeatherService.get_daily_weather(coordinates)
          hourly_weather = WeatherService.get_hourly_weather(coordinates)

          weather = Weather.new(
            current_weather:,
            daily_weather:,
            hourly_weather:,
            weather_at_eta:
          )

          forecast = ForecastSerializer.format(weather, coordinates)
          render json: forecast
        else
          render json: { error: 'Invalid location' }, status: 400
        end
      end
    end
  end
end
