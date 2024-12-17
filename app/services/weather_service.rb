require 'net/http'
require 'json'
require 'nokogiri'

class WeatherService
  BASE_URL = 'https://weather.tsukumijima.net/api/forecast/city/'.freeze
  # 定数を削除して、メソッド引数から受け取る設計に変更
  
  # 第一のソース用メソッド: city_idを引数で受け取る
  def self.fetch_precipitation_from_source_1(city_id)
    url = URI.parse("#{BASE_URL}#{city_id}")
    response = Net::HTTP.get(url)
    weather_data = JSON.parse(response)

    if weather_data['forecasts'] && weather_data['forecasts'][0]['chanceOfRain']
      chance_of_rain = weather_data['forecasts'][0]['chanceOfRain']
      if chance_of_rain
        # 対象となる時間帯キーのリスト
        times = ['T00_06', 'T06_12', 'T12_18', 'T18_24']
        # 存在するキーに対して、値を整数化して配列に格納
        values = times.map { |t| chance_of_rain[t].to_i if chance_of_rain[t] }.compact
        if values.any?
          # 存在する値の平均
          max_value = values.max
          min_value = values.min
          average_value = values.sum / values.size.to_f
          { max: max_value, average: average_value, min: min_value }
        else
          nil
        end
      else
        nil
      end
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching precipitation: #{e.message}")
    nil
  end

  # 第二のソース用メソッド: JMAのURL形式に合わせて、パラメータで地域コードを変更できるようにする
  # 例えば、130010は八王子、他の地域は異なるコードを割り当てることが可能
  def self.fetch_precipitation_from_source_2(jma_area_code)
    jma_api_url = "https://www.jma.go.jp/bosai/forecast/data/forecast/#{jma_area_code}.json"
    uri = URI(jma_api_url)
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

  # 第三のソース用メソッド: 座標を引数で受け取り、Yahoo Weather APIのURLを動的に生成
  def self.fetch_precipitation_from_source_3(latitude, longitude)
    appid = 'dj00aiZpPUpKU2Nkd2Zxb2x1QiZzPWNvbnN1bWVyc2VjcmV0Jng9MTU-'
    uri = URI("https://map.yahooapis.jp/weather/V1/place?coordinates=#{longitude},#{latitude}&appid=#{appid}")

    res = Net::HTTP.get_response(uri)

    if res.is_a?(Net::HTTPSuccess)
      xml = Nokogiri::XML(res.body)
      namespace = { 'ns' => 'http://olp.yahooapis.jp/ydf/1.0' }

      rainfall_values = xml.xpath('//ns:Rainfall', namespace).map(&:text).map(&:to_f)

      if rainfall_values.any?
        average_rainfall = (rainfall_values.sum / rainfall_values.size) * 100
        average_rainfall.round(2)
      else
        nil
      end
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching precipitation from Yahoo Weather API: #{e.message}")
    nil
  end

  # 新規追加メソッド: 複数日分の予報を取得
  # @return [Array<Hash>] 例: [{ date: '2024-12-18', precipitation: 40.0 }, { date: '2024-12-19', precipitation: 30.0 }, ... ]
  def self.fetch_forecasts(city_id)
    url = URI.parse("#{BASE_URL}#{city_id}")
    response = Net::HTTP.get(url)
    weather_data = JSON.parse(response)

    return [] unless weather_data['forecasts']

    # forecastsは複数日分存在する想定
    forecasts = weather_data['forecasts'].map do |forecast|
      date = forecast['date']
      chance_of_rain = forecast['chanceOfRain']

      if chance_of_rain
        times = ['T00_06', 'T06_12', 'T12_18', 'T18_24']
        values = times.map { |t| chance_of_rain[t].to_i if chance_of_rain[t] }.compact
        if values.any?
          average_value = values.sum / values.size.to_f
          { date: date, precipitation: average_value }
        else
          { date: date, precipitation: nil }
        end
      else
        { date: date, precipitation: nil }
      end
    end

    forecasts
  rescue StandardError => e
    Rails.logger.error("Error fetching multi-day forecasts: #{e.message}")
    []
  end
end
