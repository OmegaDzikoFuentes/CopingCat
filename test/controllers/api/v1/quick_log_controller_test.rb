require "test_helper"

class Api::V1::QuickLogControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_quick_log_create_url
    assert_response :success
  end
end
