# frozen_string_literal: true

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

    # 複数日、複数ソースを統合した予報データを取得
    # @forecasts: [{date: '2024-12-18', average: X, max: Y, min:Z, source_count: N}, ...]
    @forecasts = WeatherService.fetch_multi_day_combined_forecasts(region_code, latitude, longitude)

    # 当日分（1日目）のデータを使って@average_precipitationなどを表示したい場合は、
    # @forecastsの最初の日付から取得するなど対応可能
    today_forecast = @forecasts.find { |f| f[:date] == Date.today.to_s }
    if today_forecast
      @average_precipitation = today_forecast[:average]
      @max_precipitation = today_forecast[:max]
      @min_precipitation = today_forecast[:min]
    else
      @average_precipitation = nil
      @max_precipitation = nil
      @min_precipitation = nil
    end
  end
end
