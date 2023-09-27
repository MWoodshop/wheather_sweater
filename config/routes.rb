Rails.application.routes.draw do
  namespace :api do
    namespace :v0 do
      get 'forecast', to: 'forecasts#show'
      resources :users, only: %i[create destroy]
      post '/sessions', to: 'sessions#create'
      post '/road_trip', to: 'road_trips#create'
    end
  end
end
