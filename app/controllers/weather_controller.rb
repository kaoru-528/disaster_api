require 'redis'
class WeatherController < ApplicationController
  def index
    region_code = params[:region_code].presence || '130010'

    coordinates_map = {
      '130010' => { lat: 35.6613427, lon: 139.3667929 }, # 東京（八王子）例
      '270000' => { lat: 34.6937,    lon: 135.5022 },    # 大阪(仮)
      '230000' => { lat: 35.1815,    lon: 136.9066 },    # 名古屋(仮)
      '016010' => { lat: 43.06417,   lon: 141.34694 },   # 札幌(仮)
      '040010' => { lat: 38.26889,   lon: 140.87194 },   # 仙台(仮)
      '400010' => { lat: 33.590355,  lon: 130.401716 },  # 福岡(仮)
      '340010' => { lat: 34.385202,  lon: 132.455293 },  # 広島(仮)
      '150010' => { lat: 37.90222,   lon: 139.02361 },   # 新潟(仮)
      '460010' => { lat: 31.560148,  lon: 130.557981 }   # 鹿児島(仮)
    }

    # マップで存在しなければデフォルトは八王子にする
    coords = coordinates_map[region_code] || coordinates_map['130010']
    latitude = coords[:lat]
    longitude = coords[:lon]

    # WeatherServiceクラスのメソッドが位置情報や地域コードを引数でとるように実装済みであることを想定
    source_1_precipitation = WeatherService.fetch_precipitation_from_source_1(region_code)
    source_2_precipitation = WeatherService.fetch_precipitation_from_source_2(region_code)
    source_3_precipitation = WeatherService.fetch_precipitation_from_source_3(latitude, longitude)

    precipitations_average = [source_1_precipitation[:average], source_2_precipitation, source_3_precipitation].compact
    precipitations_max = [source_1_precipitation[:max], source_2_precipitation, source_3_precipitation].compact
    precipitations_min = [source_1_precipitation[:min], source_2_precipitation, source_3_precipitation].compact

    if precipitations_average.any? && precipitations_max.any?
      @average_precipitation = precipitations_average.sum / precipitations_average.size.to_f
      @max_precipitation = precipitations_max.max
      @min_precipitation = precipitations_min.min
    else
      @average_precipitation = nil
      @max_precipitation = nil
      @min_precipitation = nil
    end
  end
end
