require "test_helper"

class GameControllerTest < ActionDispatch::IntegrationTest
  test "should get Controller" do
    get game_Controller_url
    assert_response :success
  end
end
