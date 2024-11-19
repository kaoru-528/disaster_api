class WeatherController < ApplicationController
  def index
    source_1_precipitation = WeatherService.fetch_precipitation_from_source_1
    source_2_precipitation = WeatherService.fetch_precipitation_from_source_2

    precipitations = [source_1_precipitation, source_2_precipitation].compact
    @average_precipitation = precipitations.sum / precipitations.size if precipitations.any?
  end
end