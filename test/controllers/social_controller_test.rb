require "test_helper"

class SocialControllerTest < ActionDispatch::IntegrationTest
  test "should get Controller" do
    get social_Controller_url
    assert_response :success
  end
end
