Rails.application.routes.draw do
  namespace :api do
    namespace :v0 do
      get 'forecast', to: 'forecasts#show'
    end

    namespace :v1 do
      get 'book-search', to: 'book_search#show'
    end
  end
end
