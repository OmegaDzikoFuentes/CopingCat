require "test_helper"

class BehaviorReactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get behavior_reactions_index_url
    assert_response :success
  end

  test "should get show" do
    get behavior_reactions_show_url
    assert_response :success
  end

  test "should get new" do
    get behavior_reactions_new_url
    assert_response :success
  end

  test "should get create" do
    get behavior_reactions_create_url
    assert_response :success
  end

  test "should get edit" do
    get behavior_reactions_edit_url
    assert_response :success
  end

  test "should get update" do
    get behavior_reactions_update_url
    assert_response :success
  end

  test "should get destroy" do
    get behavior_reactions_destroy_url
    assert_response :success
  end
end
