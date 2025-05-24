require "test_helper"

class TriggersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get triggers_index_url
    assert_response :success
  end

  test "should get show" do
    get triggers_show_url
    assert_response :success
  end

  test "should get new" do
    get triggers_new_url
    assert_response :success
  end

  test "should get create" do
    get triggers_create_url
    assert_response :success
  end

  test "should get edit" do
    get triggers_edit_url
    assert_response :success
  end

  test "should get update" do
    get triggers_update_url
    assert_response :success
  end

  test "should get destroy" do
    get triggers_destroy_url
    assert_response :success
  end
end
