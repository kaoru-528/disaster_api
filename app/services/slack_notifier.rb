require 'net/http'
require 'uri'
require 'json'

class SlackNotifier
  def self.notify(message, webhook_url)
    uri = URI.parse(webhook_url)
    header = { 'Content-Type': 'application/json' }
    payload = { text: message }.to_json

    response = Net::HTTP.post(uri, payload, header)

    if response.code == '200'
      Rails.logger.info('Slack通知成功')
    else
      Rails.logger.error("Slack通知失敗: #{response.body}")
    end
  end
end