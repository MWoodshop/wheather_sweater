require 'rails_helper'

RSpec.describe Api::V0::UsersController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) { { email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
    let(:invalid_attributes) do
      { email: 'test@example.com', password: 'password', password_confirmation: 'wrong_password' }
    end

    context 'with valid attributes' do
      it 'creates a new User' do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new User' do
        expect do
          post :create, params: invalid_attributes
        end.to change(User, :count).by(0)
      end
    end

    context 'when email already exists' do
      before { User.create(valid_attributes) }

      it 'does not create a new User' do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(0)

        expect(response.body).to include('Email already exists')
        expect(response.status).to eq(400)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { User.create(email: 'test@example.com', password: 'password', password_confirmation: 'password') }

    it 'destroys the requested user' do
      expect do
        delete :destroy, params: { id: user.to_param }
      end.to change(User, :count).by(-1)
    end

    it 'will return an error and not destroy a user that does not exist' do
      expect do
        delete :destroy, params: { id: 0 }
      end.to change(User, :count).by(0)

      expect(response.body).to include('User not found')
      expect(response.status).to eq(404)
    end
  end
end
