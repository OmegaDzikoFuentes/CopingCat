require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get analytics_dashboard_url
    assert_response :success
  end

  test "should get emotions" do
    get analytics_emotions_url
    assert_response :success
  end

  test "should get triggers" do
    get analytics_triggers_url
    assert_response :success
  end

  test "should get patterns" do
    get analytics_patterns_url
    assert_response :success
  end

  test "should get export" do
    get analytics_export_url
    assert_response :success
  end
end
