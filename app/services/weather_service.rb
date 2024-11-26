require 'net/http'
require 'json'

class WeatherService
  BASE_URL = 'https://weather.tsukumijima.net/api/forecast/city/'.freeze
  HACHIOJI_ID = '130010'.freeze # 八王子市のID
  JMA_API_URL = 'https://www.jma.go.jp/bosai/forecast/data/forecast/130010.json'.freeze # 八王子市のコード

  def self.fetch_precipitation_from_source_1
    url = URI.parse("#{BASE_URL}#{HACHIOJI_ID}")
    response = Net::HTTP.get(url)
    weather_data = JSON.parse(response)

    if weather_data['forecasts'] && weather_data['forecasts'][0]['chanceOfRain']
      chance_of_rain = weather_data['forecasts'][0]['chanceOfRain']
      chance_of_rain['T18_24'].to_i if chance_of_rain['T18_24']
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching precipitation: #{e.message}")
    nil
  end

  def self.fetch_precipitation_from_source_2
    uri = URI(JMA_API_URL)
    response = Net::HTTP.get(uri)
    weather_data = JSON.parse(response)

    area_name = weather_data[0].dig('timeSeries', 1, 'areas', 0, 'area', 'name')
    pops = weather_data[0].dig('timeSeries', 1, 'areas', 0, 'pops')

    if pops && pops[0]
      puts "地域: #{area_name}, 降水確率: #{pops[0]}%"
      pops[0].to_i
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching precipitation from JMA API: #{e.message}")
    nil
  end

  def self.fetch_precipitation_from_source_3
  # URIを設定
  uri = URI('https://map.yahooapis.jp/weather/V1/place?coordinates=139.3667929,35.6613427&appid=dj00aiZpPUpKU2Nkd2Zxb2x1QiZzPWNvbnN1bWVyc2VjcmV0Jng9MTU-')

  # リクエストを送信
  res = Net::HTTP.get_response(uri)

  if res.is_a?(Net::HTTPSuccess)
    # レスポンスボディをXMLとしてパース
    xml = Nokogiri::XML(res.body)

    # 名前空間を登録
    namespace = { 'ns' => 'http://olp.yahooapis.jp/ydf/1.0' }

    # Rainfall値を抽出し、数値に変換
    rainfall_values = xml.xpath('//ns:Rainfall', namespace).map(&:text).map(&:to_f)

    # 平均値を計算
    average_rainfall = (rainfall_values.sum / rainfall_values.size) * 100

    # 結果を表示（平均降水量）
    average_rainfall.round(2)
  else
    nil
  end
  rescue StandardError => e
    Rails.logger.error("Error fetching precipitation from JMA API: #{e.message}")
    nil
  end
end