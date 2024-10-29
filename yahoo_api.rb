# nethttp.rb
require 'uri'
require 'net/http'

uri = URI('https://map.yahooapis.jp/weather/V1/place?coordinates=139.3667929,35.6613427&appid={Client ID}')
res = Net::HTTP.get_response(uri)
puts res.body if res.is_a?(Net::HTTPSuccess)