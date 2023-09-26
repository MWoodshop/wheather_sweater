require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'should validate presence of email' do
      user = User.new(password: 'password', password_confirmation: 'password')
      expect(user).not_to be_valid
      expect(user.errors.messages[:email]).to include("can't be blank")
    end

    it 'should validate uniqueness of email' do
      User.create(email: 'test@example.com', password: 'password', password_confirmation: 'password')
      user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'password')
      expect(user).not_to be_valid
      expect(user.errors.messages[:email]).to include('has already been taken')
    end

    it 'should validate presence of password' do
      user = User.new(email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors.messages[:password]).to include("can't be blank")
    end

    it 'should validate password confirmation' do
      user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'different_password')
      expect(user).not_to be_valid
      expect(user.errors.messages[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'before_create callback' do
    it 'should generate an API key before creating a user' do
      user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'password')
      expect(user.api_key).to be_nil
      user.save
      expect(user.api_key).not_to be_nil
    end
  end
end
