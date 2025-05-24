require "test_helper"

class UserGoalsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_goals_index_url
    assert_response :success
  end

  test "should get show" do
    get user_goals_show_url
    assert_response :success
  end

  test "should get new" do
    get user_goals_new_url
    assert_response :success
  end

  test "should get create" do
    get user_goals_create_url
    assert_response :success
  end

  test "should get edit" do
    get user_goals_edit_url
    assert_response :success
  end

  test "should get update" do
    get user_goals_update_url
    assert_response :success
  end

  test "should get destroy" do
    get user_goals_destroy_url
    assert_response :success
  end

  test "should get complete" do
    get user_goals_complete_url
    assert_response :success
  end

  test "should get pause" do
    get user_goals_pause_url
    assert_response :success
  end
end
