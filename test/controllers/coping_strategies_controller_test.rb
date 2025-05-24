require "test_helper"

class CopingStrategiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get coping_strategies_index_url
    assert_response :success
  end

  test "should get show" do
    get coping_strategies_show_url
    assert_response :success
  end

  test "should get new" do
    get coping_strategies_new_url
    assert_response :success
  end

  test "should get create" do
    get coping_strategies_create_url
    assert_response :success
  end

  test "should get edit" do
    get coping_strategies_edit_url
    assert_response :success
  end

  test "should get update" do
    get coping_strategies_update_url
    assert_response :success
  end

  test "should get destroy" do
    get coping_strategies_destroy_url
    assert_response :success
  end
end
