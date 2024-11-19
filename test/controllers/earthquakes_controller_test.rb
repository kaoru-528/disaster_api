require "test_helper"

class EarthquakesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get earthquakes_index_url
    assert_response :success
  end
end
