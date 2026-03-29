require "test_helper"

class TownHall::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post town_hall_session_path, params: {email: stewards(:one).email, password: "password"}
  end

  test "edit requires authentication" do
    delete town_hall_session_path
    get edit_town_hall_profile_path
    assert_redirected_to new_town_hall_session_path
  end

  test "edit shows current steward profile form" do
    get edit_town_hall_profile_path
    assert_response :success
    assert_select "input[name='steward[first_name]'][value='Admin']"
    assert_select "input[name='steward[email]']"
  end

  test "update changes name and email" do
    patch town_hall_profile_path, params: {
      steward: {first_name: "Updated", last_name: "Name", email: "updated@example.com"}
    }
    assert_redirected_to edit_town_hall_profile_path

    steward = stewards(:one).reload
    assert_equal "Updated", steward.first_name
    assert_equal "Name", steward.last_name
    assert_equal "updated@example.com", steward.email
  end

  test "update changes phone" do
    patch town_hall_profile_path, params: {
      steward: {mobile_phone: "828-555-1234"}
    }
    assert_redirected_to edit_town_hall_profile_path
    assert_equal "828-555-1234", stewards(:one).reload.mobile_phone
  end

  test "update changes password when provided" do
    patch town_hall_profile_path, params: {
      steward: {password: "newpassword", password_confirmation: "newpassword"}
    }
    assert_redirected_to edit_town_hall_profile_path
    assert stewards(:one).reload.authenticate("newpassword")
  end

  test "update ignores blank password" do
    patch town_hall_profile_path, params: {
      steward: {first_name: "Changed", password: "", password_confirmation: ""}
    }
    assert_redirected_to edit_town_hall_profile_path
    assert_equal "Changed", stewards(:one).reload.first_name
    assert stewards(:one).authenticate("password")
  end

  test "update with invalid data renders edit" do
    patch town_hall_profile_path, params: {
      steward: {email: ""}
    }
    assert_response :unprocessable_entity
  end

  test "header links steward name to profile" do
    get town_hall_stewards_path
    assert_select "a[href=?]", edit_town_hall_profile_path, text: stewards(:one).full_name
  end
end
