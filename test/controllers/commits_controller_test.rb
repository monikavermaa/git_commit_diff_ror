require "test_helper"

class CommitsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get commits_show_url
    assert_response :success
  end
end
