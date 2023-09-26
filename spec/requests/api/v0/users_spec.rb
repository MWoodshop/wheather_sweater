# spec/requests/api/v0/user_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V0::Users', type: :request do
  describe 'POST /create' do
    let(:valid_attributes) do
      { email: 'test@example.com', password: 'password', password_confirmation: 'password' }
    end

    let(:invalid_attributes) do
      { email: 'test@example.com', password: 'password', password_confirmation: 'wrong_password' }
    end

    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post '/api/v0/users', params: valid_attributes
        end.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post '/api/v0/users', params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
        expect(JSON.parse(response.body)['data']['attributes']['email']).to eq('test@example.com')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect do
          post '/api/v0/users', params: invalid_attributes
        end.to change(User, :count).by(0)
      end

      it 'renders a JSON response with errors for the new user' do
        post '/api/v0/users', params: invalid_attributes

        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
