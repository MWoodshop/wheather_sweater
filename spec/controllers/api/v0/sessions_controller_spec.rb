require 'rails_helper'

RSpec.describe Api::V0::SessionsController, type: :controller do
  describe 'POST #create' do
    let!(:user) { User.create(email: 'whatever@example.com', password: 'password', password_confirmation: 'password') }
    let(:valid_credentials) { { email: 'whatever@example.com', password: 'password' } }
    let(:invalid_credentials) { { email: 'whatever@example.com', password: 'wrongpassword' } }

    context 'when credentials are valid' do
      before { post :create, params: valid_credentials }

      it 'returns 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the user api_key in the response body' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data']['attributes']['api_key']).to eq(user.api_key)
      end
    end

    context 'when credentials are invalid' do
      before { post :create, params: invalid_credentials }

      it 'returns 401 status code' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Invalid credentials')
      end
    end
  end
end
