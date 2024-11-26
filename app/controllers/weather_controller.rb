class WeatherController < ApplicationController
  def index
    # region_code = get_region_code(city_name)
    region_code = '130010' # 八王子市のregion_code

    source_1_precipitation = WeatherService.fetch_precipitation_from_source_1
    source_2_precipitation = WeatherService.fetch_precipitation_from_source_2
    source_3_precipitation = WeatherService.fetch_precipitation_from_source_3

    precipitations = [source_1_precipitation, source_2_precipitation, source_3_precipitation].compact
    @average_precipitation = precipitations.sum / precipitations.size if precipitations.any?
  end
end