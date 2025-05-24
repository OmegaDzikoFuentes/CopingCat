require "test_helper"

class PredictionFeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prediction_feedbacks_index_url
    assert_response :success
  end

  test "should get show" do
    get prediction_feedbacks_show_url
    assert_response :success
  end

  test "should get new" do
    get prediction_feedbacks_new_url
    assert_response :success
  end

  test "should get create" do
    get prediction_feedbacks_create_url
    assert_response :success
  end

  test "should get edit" do
    get prediction_feedbacks_edit_url
    assert_response :success
  end

  test "should get update" do
    get prediction_feedbacks_update_url
    assert_response :success
  end

  test "should get destroy" do
    get prediction_feedbacks_destroy_url
    assert_response :success
  end

  test "should get quick_feedback" do
    get prediction_feedbacks_quick_feedback_url
    assert_response :success
  end
end
