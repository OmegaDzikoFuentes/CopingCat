require "test_helper"

class PhysicalSymptomsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get physical_symptoms_index_url
    assert_response :success
  end

  test "should get show" do
    get physical_symptoms_show_url
    assert_response :success
  end

  test "should get new" do
    get physical_symptoms_new_url
    assert_response :success
  end

  test "should get create" do
    get physical_symptoms_create_url
    assert_response :success
  end

  test "should get edit" do
    get physical_symptoms_edit_url
    assert_response :success
  end

  test "should get update" do
    get physical_symptoms_update_url
    assert_response :success
  end

  test "should get destroy" do
    get physical_symptoms_destroy_url
    assert_response :success
  end

  test "should get quick_add" do
    get physical_symptoms_quick_add_url
    assert_response :success
  end
end
