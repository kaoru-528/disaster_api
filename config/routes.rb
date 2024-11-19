Rails.application.routes.draw do
  root 'earthquakes#index'
  get 'tenki_earthquakes', to: 'tenki_earthquakes#index'
end