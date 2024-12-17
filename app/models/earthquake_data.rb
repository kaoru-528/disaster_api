require 'net/http'
require 'uri'
require 'json'
require 'time'

class Earthquake
  def initialize(data)
    @data = data
  end

  def label
    "#{earthquake_type} " +
      "#{@data['earthquake']['time']} " +
      "震度#{scale} " +
      "#{hypocenter} " +
      "#{tsunami_type}"
  end

  private

  def earthquake_type
    {
      'ScalePrompt' => '震度速報',
      'Destination' => '震源情報',
      'ScaleAndDestination' => '震度・震源情報',
      'DetailScale' => '地震情報',
      'Foreign' => '遠地地震'
    }[@data.dig('issue', 'type')] || '不明な地震情報'
  end

  def tsunami_type
    {
      'None' => '津波の心配なし',
      'Checking' => '津波有無は調査中',
      'NonEffective' => '津波被害の心配なし(若干の海面変動あり)',
      'Watch' => '津波注意報発表中',
      'Warning' => '津波予報発表中'
    }[@data.dig('earthquake', 'domesticTsunami')] || '津波有無は不明'
  end

  def scale
    {
      10 => 1,
      20 => 2,
      30 => 3,
      40 => 4,
      45 => '5弱',
      50 => '5強',
      55 => '6弱',
      60 => '6強',
      70 => 7
    }[@data.dig('earthquake', 'maxScale')] || '不明'
  end

  def hypocenter
    hypo_params = @data.dig('earthquake', 'hypocenter')
    return nil if !hypo_params || hypo_params['name'].empty?

    "#{hypo_params['name']}(#{hypo_params['depth']}, M#{hypo_params['magnitude']})"
  end
end

class Tsunami
  def initialize(data)
    @data = data
  end

  def label
    '津波予報 ' +
      "#{Time.parse(@data['time']).strftime('%d日%H時%M分')} " +
      "#{@data['cancelled'] ? 'すべて解除' : '発表'}"
  end
end

class Userquake
  def initialize(data)
    @data = data
  end

  def label
    '地震感知情報 ' +
      "#{Time.parse(@data['time']).strftime('%d日%H時%M分')} " +
      "#{@data['prefs'].sort_by { |_k, v| -v }.map { |k, v| "#{k}(#{v})" }.join(' ')}"
  end
end

class EarthquakeData
  def self.fetch
    code2class = {
      551 => Earthquake,
      552 => Tsunami,
      5610 => Userquake
    }

    uri = URI.parse('https://api.p2pquake.net/v2/jma/quake')
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    json.map do |record|
      clazz = code2class[record['code']]
      clazz.new(record) if clazz
    end.compact
  end
end
