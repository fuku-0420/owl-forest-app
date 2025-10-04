require "test_helper"

class OwlsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get owls_url  # owls_index_url → owls_url に変更
    assert_response :success
  end

  test "should get show" do
    get owl_url(owls(:one))  # owls_show_url → owl_url に変更
    assert_response :success
  end
end