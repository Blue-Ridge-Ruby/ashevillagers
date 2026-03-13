require "test_helper"

class TownHall::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post town_hall_session_path, params: { email: stewards(:one).email, password: "password" }
  end

  test "index requires authentication" do
    delete town_hall_session_path
    get town_hall_configurations_path
    assert_redirected_to new_town_hall_session_path
  end

  test "index" do
    get town_hall_configurations_path
    assert_response :success
    assert_select "table"
  end

  test "index displays masked value for secrets" do
    get town_hall_configurations_path
    assert_response :success
    assert_no_match "sk_live_abc123xyz", response.body
    assert_match "3xyz", response.body
  end

  test "new" do
    get new_town_hall_configuration_path
    assert_response :success
  end

  test "create" do
    assert_difference "Configuration.count", 1 do
      post town_hall_configurations_path, params: {
        configuration: { name: "new_setting", value: "new_value" }
      }
    end
    assert_redirected_to town_hall_configurations_path
  end

  test "create with invalid data" do
    assert_no_difference "Configuration.count" do
      post town_hall_configurations_path, params: {
        configuration: { name: "", value: "val" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit" do
    get edit_town_hall_configuration_path(configurations(:site_name))
    assert_response :success
  end

  test "update" do
    config = configurations(:site_name)
    patch town_hall_configuration_path(config), params: {
      configuration: { value: "New Name" }
    }
    assert_redirected_to town_hall_configurations_path
    assert_equal "New Name", config.reload.value
  end

  test "update with invalid data" do
    config = configurations(:site_name)
    patch town_hall_configuration_path(config), params: {
      configuration: { name: "" }
    }
    assert_response :unprocessable_entity
  end

  test "destroy" do
    assert_difference "Configuration.count", -1 do
      delete town_hall_configuration_path(configurations(:site_name))
    end
    assert_redirected_to town_hall_configurations_path
  end
end
