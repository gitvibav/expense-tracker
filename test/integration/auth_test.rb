require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  test "sign in and sign out" do
    john = users(:john)

    get dashboard_path
    assert_response :success

    post session_path, params: { email: john.email, password: "password" }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    delete session_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end

