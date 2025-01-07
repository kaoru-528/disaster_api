set :output, "log/cron.log" # ログ出力先
set :environment, "development" # 環境指定

every 5.minutes do
  rake "weather:notify_to_slack"
end