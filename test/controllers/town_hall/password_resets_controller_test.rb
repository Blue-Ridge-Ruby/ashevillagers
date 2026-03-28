require "test_helper"

class TownHall::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "get new" do
    get new_town_hall_password_reset_path
    assert_response :success
  end

  test "create with valid email sends reset and redirects" do
    assert_enqueued_emails 1 do
      post town_hall_password_reset_path, params: {email: stewards(:one).email}
    end
    assert_redirected_to new_town_hall_session_path
  end

  test "create with unknown email still redirects with same message" do
    assert_no_enqueued_emails do
      post town_hall_password_reset_path, params: {email: "nobody@example.com"}
    end
    assert_redirected_to new_town_hall_session_path
    follow_redirect!
    assert_match "If that email exists", response.body
  end

  test "edit with valid token" do
    token = stewards(:one).generate_token_for(:password_reset)
    get edit_town_hall_password_reset_path(token: token)
    assert_response :success
  end

  test "edit with invalid token redirects" do
    get edit_town_hall_password_reset_path(token: "bad-token")
    assert_redirected_to new_town_hall_password_reset_path
  end

  test "update with valid token and matching passwords" do
    token = stewards(:one).generate_token_for(:password_reset)
    patch town_hall_password_reset_path(token: token), params: {
      password: "newpassword",
      password_confirmation: "newpassword"
    }
    assert_redirected_to new_town_hall_session_path

    # Verify new password works
    steward = Steward.authenticate_by(email: stewards(:one).email, password: "newpassword")
    assert_not_nil steward
  end

  test "update with invalid token redirects" do
    patch town_hall_password_reset_path(token: "bad-token"), params: {
      password: "newpassword",
      password_confirmation: "newpassword"
    }
    assert_redirected_to new_town_hall_password_reset_path
  end

  test "update with mismatched passwords re-renders form" do
    token = stewards(:one).generate_token_for(:password_reset)
    patch town_hall_password_reset_path(token: token), params: {
      password: "newpassword",
      password_confirmation: "different"
    }
    assert_response :unprocessable_entity
  end
end
