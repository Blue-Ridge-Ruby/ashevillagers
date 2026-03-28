require "test_helper"
require "ostruct"

class TownHall::VillagersControllerTest < ActionDispatch::IntegrationTest
  setup do
    post town_hall_session_path, params: {email: stewards(:one).email, password: "password"}
  end

  test "index requires authentication" do
    delete town_hall_session_path
    get town_hall_villagers_path
    assert_redirected_to new_town_hall_session_path
  end

  test "index" do
    get town_hall_villagers_path
    assert_response :success
    assert_select "table"
  end

  test "new" do
    get new_town_hall_villager_path
    assert_response :success
  end

  test "create" do
    assert_difference "Villager.count", 1 do
      post town_hall_villagers_path, params: {
        villager: {first_name: "New", last_name: "Villager", email: "new@example.com"}
      }
    end
    assert_redirected_to town_hall_villagers_path
  end

  test "create with invalid data" do
    assert_no_difference "Villager.count" do
      post town_hall_villagers_path, params: {
        villager: {first_name: "", last_name: "", email: ""}
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit" do
    get edit_town_hall_villager_path(villagers(:one))
    assert_response :success
  end

  test "update" do
    villager = villagers(:one)
    patch town_hall_villager_path(villager), params: {
      villager: {first_name: "Updated"}
    }
    assert_redirected_to town_hall_villagers_path
    assert_equal "Updated", villager.reload.first_name
  end

  test "update with invalid data" do
    patch town_hall_villager_path(villagers(:one)), params: {
      villager: {email: ""}
    }
    assert_response :unprocessable_entity
  end

  test "destroy" do
    assert_difference "Villager.count", -1 do
      delete town_hall_villager_path(villagers(:one))
    end
    assert_redirected_to town_hall_villagers_path
  end

  test "sync skips already-linked tickets" do
    stub_tito_tickets [fake_ticket(slug: "abc123", email: "jane@example.com")] do
      assert_no_difference "Villager.count" do
        post sync_town_hall_villagers_path
      end
      assert_redirected_to town_hall_villagers_path
      follow_redirect!
      assert_match "1 already linked", response.body
    end
  end

  test "sync connects ticket to existing villager by email" do
    stub_tito_tickets [fake_ticket(slug: "new_slug", email: "pat@example.com", first_name: "Patricia", last_name: "Taylor")] do
      assert_no_difference "Villager.count" do
        post sync_town_hall_villagers_path
      end
      assert_redirected_to town_hall_villagers_path
      follow_redirect!
      assert_match "1 connected", response.body

      villager = villagers(:unlinked).reload
      assert_equal "new_slug", villager.tito_ticket_slug
      assert_equal "Patricia", villager.first_name
      assert_equal "Taylor", villager.last_name
    end
  end

  test "sync creates new villager for unknown ticket" do
    stub_tito_tickets [fake_ticket(slug: "brand_new", email: "brand_new@example.com", first_name: "Brand", last_name: "New")] do
      assert_difference "Villager.count", 1 do
        post sync_town_hall_villagers_path
      end
      assert_redirected_to town_hall_villagers_path
      follow_redirect!
      assert_match "1 added", response.body

      villager = Villager.find_by(tito_ticket_slug: "brand_new")
      assert_equal "brand_new@example.com", villager.email
      assert_equal "Brand", villager.first_name
    end
  end

  test "sync handles mix of all three cases" do
    tickets = [
      fake_ticket(slug: "abc123", email: "jane@example.com"),
      fake_ticket(slug: "connect_me", email: "pat@example.com", first_name: "Patricia", last_name: "Taylor"),
      fake_ticket(slug: "new_one", email: "someone@example.com", first_name: "Some", last_name: "One")
    ]

    stub_tito_tickets tickets do
      assert_difference "Villager.count", 1 do
        post sync_town_hall_villagers_path
      end
      assert_redirected_to town_hall_villagers_path
      follow_redirect!
      assert_match "1 already linked", response.body
      assert_match "1 connected", response.body
      assert_match "1 added", response.body
    end
  end

  private

  def fake_ticket(slug:, email:, first_name: "Test", last_name: "User")
    OpenStruct.new(slug: slug, email: email, first_name: first_name, last_name: last_name)
  end

  def stub_tito_tickets(tickets)
    mock_client = OpenStruct.new(tickets: tickets)
    original = Villager.method(:tito_client)
    Villager.define_singleton_method(:tito_client) { mock_client }
    yield
  ensure
    Villager.define_singleton_method(:tito_client, original)
  end
end
