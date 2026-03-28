require "test_helper"

class VillagerTest < ActiveSupport::TestCase
  test "valid with only email" do
    villager = Villager.new(email: "ada@example.com")
    assert villager.valid?
  end

  test "valid with only tito_ticket_slug" do
    villager = Villager.new(tito_ticket_slug: "ti_abc123")
    assert villager.valid?
  end

  test "valid with both email and tito_ticket_slug" do
    villager = Villager.new(email: "ada@example.com", tito_ticket_slug: "ti_abc123")
    assert villager.valid?
  end

  test "invalid without email or tito_ticket_slug" do
    villager = Villager.new
    assert_not villager.valid?
  end

  test "valid without names in default context" do
    villager = Villager.new(email: "ada@example.com")
    assert villager.valid?
  end

  test "invalid without first_name in interactive context" do
    villager = Villager.new(email: "ada@example.com", last_name: "Lovelace")
    assert_not villager.valid?(:interactive)
  end

  test "invalid without last_name in interactive context" do
    villager = Villager.new(email: "ada@example.com", first_name: "Ada")
    assert_not villager.valid?(:interactive)
  end

  test "valid with all fields in interactive context" do
    villager = Villager.new(email: "ada@example.com", first_name: "Ada", last_name: "Lovelace")
    assert villager.valid?(:interactive)
  end

  test "normalizes email to lowercase and stripped" do
    villager = Villager.new(first_name: "Ada", last_name: "Lovelace", email: "  ADA@Example.COM  ")
    assert_equal "ada@example.com", villager.email
  end

  test "generates a login token that resolves back to the villager" do
    villager = villagers(:one)
    token = villager.generate_token_for(:login)
    assert_equal villager, Villager.find_by_token_for(:login, token)
  end

  test "login token from a different villager does not resolve" do
    token = villagers(:one).generate_token_for(:login)
    assert_not_equal villagers(:two), Villager.find_by_token_for(:login, token)
  end
end
