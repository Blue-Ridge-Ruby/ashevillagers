require "test_helper"

class TownHall::StewardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post town_hall_session_path, params: {email: stewards(:one).email, password: "password"}
  end

  test "index requires authentication" do
    delete town_hall_session_path
    get town_hall_stewards_path
    assert_redirected_to new_town_hall_session_path
  end

  test "index" do
    get town_hall_stewards_path
    assert_response :success
    assert_select "table"
  end

  test "new" do
    get new_town_hall_steward_path
    assert_response :success
  end

  test "create" do
    assert_difference "Steward.count", 1 do
      post town_hall_stewards_path, params: {
        steward: {
          email: "new@example.com",
          first_name: "New",
          last_name: "Steward",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_redirected_to town_hall_stewards_path
  end

  test "create with invalid data" do
    assert_no_difference "Steward.count" do
      post town_hall_stewards_path, params: {
        steward: {email: "", first_name: "", last_name: "", password: ""}
      }
    end
    assert_response :unprocessable_entity
  end

  test "destroy" do
    steward = stewards(:two)
    assert_difference "Steward.count", -1 do
      delete town_hall_steward_path(steward)
    end
    assert_redirected_to town_hall_stewards_path
  end

  test "cannot delete self" do
    steward = stewards(:one)
    assert_no_difference "Steward.count" do
      delete town_hall_steward_path(steward)
    end
    assert_redirected_to town_hall_stewards_path
    follow_redirect!
    assert_match "cannot delete yourself", response.body
  end
end
