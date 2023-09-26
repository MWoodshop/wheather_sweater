module Api
  module V0
    class SessionsController < ApplicationController
      def create
        user = User.find_by(email: params[:email])

        if user && user.authenticate(params[:password])
          render json: {
            data: {
              type: 'users',
              id: user.id,
              attributes: {
                email: user.email,
                api_key: user.api_key
              }
            }
          }, status: 200
        else
          render json: { error: 'Invalid credentials' }, status: 401
        end
      end
    end
  end
end
