require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get Controller" do
    get registrations_Controller_url
    assert_response :success
  end
end
