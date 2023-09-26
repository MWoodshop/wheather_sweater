class Api::V0::UsersController < ApplicationController
  def create
    if User.exists?(email: params[:email])
      render json: { error: 'Email already exists' }, status: 400
      return
    end

    user = User.new(user_params)

    if user.save
      render json: { data: { type: 'users', id: user.id, attributes: { email: user.email, api_key: user.api_key } } },
             status: 201
    else
      render json: { error: user.errors.full_messages.join(', ') }, status: 400
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    if user
      user.destroy
      render json: { message: 'User deleted successfully' }, status: 200
    else
      render json: { error: 'User not found' }, status: 404
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
