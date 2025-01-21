namespace :weather do
    desc '天気予報をSlackに通知する'
    task notify_to_slack: :environment do
      # 地域コードと緯度経度を設定
      region_code = '130010' # 東京
      latitude, longitude = 35.6895, 139.6917 # 東京の緯度経度
      webhook_url = 'https://hooks.slack.com/services/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'

      # WeatherServiceを利用してSlackに通知
      WeatherService.notify_weather_to_slack(region_code, latitude, longitude, webhook_url)
    end
  end