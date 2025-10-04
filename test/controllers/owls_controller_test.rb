require "test_helper"

class OwlsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get owls_index_url
    assert_response :success
  end

  test "should get show" do
    get owls_show_url
    assert_response :success
  end
end
