namespace :weather do
    desc '天気予報をSlackに通知する'
    task notify_to_slack: :environment do
      # 地域コードと緯度経度を設定
      region_code = '130000' # 東京
      latitude, longitude = 35.6895, 139.6917 # 東京の緯度経度
      webhook_url = 'https://hooks.slack.com/services/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'

      # WeatherServiceを利用してSlackに通知
      WeatherService.notify_weather_to_slack(region_code, latitude, longitude, webhook_url)
    end
  end