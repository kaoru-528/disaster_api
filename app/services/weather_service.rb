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
        times = %w[T00_06 T06_12 T12_18 T18_24]
        # 存在するキーに対して、値を整数化して配列に格納
        values = times.map { |t| chance_of_rain[t].to_i if chance_of_rain[t] }.compact
        if values.any?
          # 存在する値の平均
          max_value = values.max
          min_value = values.min
          average_value = values.sum / values.size.to_f
          { max: max_value, average: average_value, min: min_value }
        end
      end
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
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching precipitation from Yahoo Weather API: #{e.message}")
    nil
  end

  # 複数日分の予報取得（Source 1）
  # 返り値例: [{ date: '2024-12-18', values: [40.0] }, { date: '2024-12-19', values: [30.0] }]
  def self.fetch_forecasts_from_source_1(city_id)
    url = URI.parse("#{BASE_URL}#{city_id}")
    response = Net::HTTP.get(url)
    weather_data = JSON.parse(response)

    return [] unless weather_data['forecasts']

    weather_data['forecasts'].map do |forecast|
      date = forecast['date']
      chance_of_rain = forecast['chanceOfRain']
      if chance_of_rain
        times = %w[T00_06 T06_12 T12_18 T18_24]
        values = times.map { |t| chance_of_rain[t].to_i if chance_of_rain[t] }.compact
        if values.any?
          # 日ごとの平均値をvaluesに格納(ここでは1日1値とする)
          avg_value = values.sum / values.size.to_f
          { date: date, values: [avg_value] }
        else
          { date: date, values: [] }
        end
      else
        { date: date, values: [] }
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching multi-day forecasts from source 1: #{e.message}")
    []
  end

  # 複数日分の予報取得（Source 2: JMA）
  # JMA APIで複数日分取得できる場合を想定
  # 戻り値形式は上と同じに合わせる
  def self.fetch_forecasts_from_source_2(jma_area_code)
    jma_api_url = "https://www.jma.go.jp/bosai/forecast/data/forecast/#{jma_area_code}.json"
    uri = URI(jma_api_url)
    response = Net::HTTP.get(uri)
    weather_data = JSON.parse(response)

    # JMAのデータ構造に合わせて複数日分を抽出するロジック（要調整）
    # ここでは仮にtimeSeries[1]のpops配列を複数日分取得できるものとする
    time_series = weather_data[0].dig('timeSeries', 1)
    pops = time_series.dig('areas', 0, 'pops') # ["10","20","30",...]の日ごとのpopを想定
    dates = time_series['timeDefines'] # ["2024-12-18T00:00:00+09:00", ...]のような日付配列を想定

    return [] if pops.nil? || dates.nil?

    # 日付とpopsを紐付けてmap
    dates.map.with_index do |datetime_str, i|
      date = Date.parse(datetime_str).to_s
      pop_val = pops[i].to_f
      { date: date, values: [pop_val] }
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching multi-day forecasts from source 2: #{e.message}")
    []
  end

  # 複数日分の予報取得（Source 3: Yahoo Weather）
  # YahooのAPIは単日しか取れない場合は別のエンドポイントを利用する必要があるかもしれません。
  # ここでは仮に複数日のデータが取れるAPIがあると仮定した例を示します。
  def self.fetch_forecasts_from_source_3(latitude, longitude)
    # 仮の複数日分取得URL（実際は存在しない場合が多いので要調整）
    appid = 'dj00aiZpPUpKU2Nkd2Zxb2x1QiZzPWNvbnN1bWVyc2VjcmV0Jng9MTU-'
    uri = URI("https://map.yahooapis.jp/weather/V1/multi_day_forecast?coordinates=#{longitude},#{latitude}&appid=#{appid}")

    res = Net::HTTP.get_response(uri)
    return [] unless res.is_a?(Net::HTTPSuccess)

    xml = Nokogiri::XML(res.body)
    namespace = { 'ns' => 'http://olp.yahooapis.jp/ydf/1.0' }

    # 仮ロジック: <Forecast date="2024-12-18"> <Rainfall>0.4</Rainfall> </Forecast> などを想定
    forecasts = xml.xpath('//ns:Forecast', namespace)
    forecasts.map do |f|
      date = f['date'] # "2024-12-18"
      rainfall_values = f.xpath('ns:Rainfall', namespace).map(&:text).map(&:to_f)
      if rainfall_values.any?
        avg_rainfall = (rainfall_values.sum / rainfall_values.size) * 100
        { date: date, values: [avg_rainfall.round(2)] }
      else
        { date: date, values: [] }
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching multi-day forecasts from source 3: #{e.message}")
    []
  end

  # 3つのソースのデータをマージして日付ごとの平均・最大・最小を計算
  def self.fetch_multi_day_combined_forecasts(region_code, latitude, longitude)
    s1_data = fetch_forecasts_from_source_1(region_code)
    s2_data = fetch_forecasts_from_source_2(region_code)
    s3_data = fetch_forecasts_from_source_3(latitude, longitude)

    # 全て結合
    all_data = [s1_data, s2_data, s3_data].flatten

    # 日付ごとにグルーピング
    grouped = all_data.group_by { |h| h[:date] }

    # 日付ごとに各ソースのvaluesをまとめて統計値算出
    # grouped例: { "2024-12-18" => [{date:"2024-12-18",values:[40.0]}, {date:"2024-12-18",values:[20.0]}, ... ] }
    grouped.map do |date, entries|
      # entriesに含まれるvaluesを全てフラット化
      all_values = entries.map { |e| e[:values] }.flatten.compact
      if all_values.any?
        {
          date: date,
          average: (all_values.sum / all_values.size.to_f),
          max: all_values.max,
          min: all_values.min,
          source_count: all_values.size
        }
      else
        {
          date: date,
          average: nil,
          max: nil,
          min: nil,
          source_count: 0
        }
      end
    end.sort_by { |h| h[:date] } # 日付でソート
  end

  def self.notify_weather_to_slack(region_code, latitude, longitude, webhook_url)
    forecasts = fetch_multi_day_combined_forecasts(region_code, latitude, longitude)

    # メッセージ生成
    message = forecasts.map do |forecast|
      "日付: #{forecast[:date]}, 降水確率 (平均): #{forecast[:average]}%"
    end.join("\n")

    # Slack通知
    SlackNotifier.notify(message, webhook_url)
  end
end
