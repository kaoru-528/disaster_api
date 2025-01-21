# frozen_string_literal: true

Rails.application.routes.draw do
  get 'weather/index'
  get 'earthquakes', to: 'earthquakes#index'
  root 'scraping#index'
  get 'tenki_earthquakes', to: 'tenki_earthquakes#index'
  get 'weather', to: 'weather#index'
end
