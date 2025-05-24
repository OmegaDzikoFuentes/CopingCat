require "test_helper"

class EmotionalEpisodesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get emotional_episodes_index_url
    assert_response :success
  end

  test "should get show" do
    get emotional_episodes_show_url
    assert_response :success
  end

  test "should get new" do
    get emotional_episodes_new_url
    assert_response :success
  end

  test "should get create" do
    get emotional_episodes_create_url
    assert_response :success
  end

  test "should get edit" do
    get emotional_episodes_edit_url
    assert_response :success
  end

  test "should get update" do
    get emotional_episodes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get emotional_episodes_destroy_url
    assert_response :success
  end

  test "should get quick_log" do
    get emotional_episodes_quick_log_url
    assert_response :success
  end

  test "should get create_quick" do
    get emotional_episodes_create_quick_url
    assert_response :success
  end
end
