require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should post create" do
    assert_difference('User.count', 1) do
    post signup_url, params: 
      { name: "John Doe",
        email: "john@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end
    assert_redirected_to login_url
  end
end
