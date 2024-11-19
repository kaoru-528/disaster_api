require 'httparty'

class WeatherService
  def self.fetch_precipitation_from_source_1
    # 例: 気象庁APIのデータを取得
    response = HTTParty.get('https://example.com/weather-api-source-1')
    if response.success?
      data = JSON.parse(response.body)
      data['precipitation'] # 降水確率をパーセントで取得
    else
      nil
    end
  end

  def self.fetch_precipitation_from_source_2
    # 例: OpenWeatherMap APIのデータを取得
    response = HTTParty.get('https://example.com/weather-api-source-2')
    if response.success?
      data = JSON.parse(response.body)
      data['rain']['1h'] # 1時間あたりの降水量
    else
      nil
    end
  end
end