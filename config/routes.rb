Rails.application.routes.draw do
  get 'weather/index'
  root 'earthquakes#index'
  get 'tenki_earthquakes', to: 'tenki_earthquakes#index'
  get 'weather', to: 'weather#index'
end