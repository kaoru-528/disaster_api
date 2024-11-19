require 'mechanize'

class TenkiEarthquakesController < ApplicationController
  def index
    agent = Mechanize.new
    page = agent.get('https://earthquake.tenki.jp/bousai/earthquake/')
    @earthquakes = parse_earthquake_data(page)
  end

  private

  def parse_earthquake_data(page)
    earthquakes = []
    page.search('table.earthquake-entries-table tr').each do |row|
      next if row.search('th').any? # ヘッダー行をスキップ
      data = row.search('td').map(&:text).map(&:strip)
      next if data.empty?
      earthquakes << {
        time: data[0],
        epicenter: data[1],
        magnitude: data[2],
        maximum_intensity: data[3]
      }
    end
    earthquakes
  end
end