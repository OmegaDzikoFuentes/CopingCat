require "test_helper"

class CatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cats_index_url
    assert_response :success
  end

  test "should get new" do
    get cats_new_url
    assert_response :success
  end

  test "should get create" do
    get cats_create_url
    assert_response :success
  end

  test "should get edit" do
    get cats_edit_url
    assert_response :success
  end

  test "should get update" do
    get cats_update_url
    assert_response :success
  end

  test "should get destroy" do
    get cats_destroy_url
    assert_response :success
  end
end
