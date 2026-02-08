require "test_helper"

class TownHall::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "get new" do
    get new_town_hall_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post town_hall_session_path, params: { email: stewards(:one).email, password: "password" }
    assert_redirected_to town_hall_stewards_path
    follow_redirect!
    assert_response :success
  end

  test "create with invalid credentials" do
    post town_hall_session_path, params: { email: stewards(:one).email, password: "wrong" }
    assert_response :unprocessable_entity
  end

  test "destroy signs out" do
    post town_hall_session_path, params: { email: stewards(:one).email, password: "password" }
    delete town_hall_session_path
    assert_redirected_to new_town_hall_session_path
  end
end
