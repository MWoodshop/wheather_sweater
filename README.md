# Project Name

Wheather, Sweater!

## Learning Goals

- Access two third party APIs at one time and gather only the needed results.
- Access the latitude and longitude of a city and state and pass that on to gather:
  - The current weather conditions.
  - The daily weather forecast.
  - The hourly weather forecast.
- Implement user registration and login.
- Implement a "Road Trip" concept to determine:
  - Current time to drive from origin to destination.
  - Weather at estimated arrival time.

## Setup

1. Clone the repository.
2. Run`bundle install`.
3. Run`rails db:migrate`.

## API Keys

You can get your own API keys by:

1. Signing up at MapQuest [here](https://developer.mapquest.com/user/login/sign-up).
2. Signing up at WeatherAPI [here](https://www.weatherapi.com/signup.aspx).

## Happy Path Endpoints

- Retrieve Weather for a City:
  ```
  GET /api/v0/forecast?location=cincinatti,oh
  Content-Type: application/json
  Accept: application/json
  ```
- Register a New User:
  ```
  POST /api/v0/users
  Content-Type: application/json
  Accept: application/json

  {
    "email": "whatever@example.com",
    "password": "password",
    "password_confirmation": "password"
  }
  ```
- Login:
  ```
  POST /api/v0/sessions
  Content-Type: application/json
  Accept: application/json

  {
    "email": "whatever@example.com",
    "password": "password"
  }
  ```
- Road Trip:
  ```
  POST /api/v0/road_trip
  Content-Type: application/json
  Accept: application/json

  body:

  {
    "origin": "Cincinatti,OH",
    "destination": "Chicago,IL",
    "api_key": "t1h2i3s4_i5s6_l7e8g9i10t11"
  }
  ```
