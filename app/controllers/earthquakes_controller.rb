# frozen_string_literal: true

class EarthquakesController < ApplicationController
  def index
    @earthquakes = EarthquakeData.fetch
    @tenki_earthquakes = TenkiEarthquakesController.new.index
  end
end
