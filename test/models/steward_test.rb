require "test_helper"

class StewardTest < ActiveSupport::TestCase
  test "valid steward" do
    steward = Steward.new(
      email: "new@example.com",
      first_name: "Test",
      last_name: "User",
      password: "password",
      password_confirmation: "password"
    )
    assert steward.valid?
  end

  test "requires email" do
    steward = stewards(:one)
    steward.email = nil
    assert_not steward.valid?
  end

  test "requires unique email" do
    steward = Steward.new(
      email: stewards(:one).email,
      first_name: "Dupe",
      last_name: "User",
      password: "password",
      password_confirmation: "password"
    )
    assert_not steward.valid?
  end

  test "normalizes email" do
    steward = Steward.new(email: "  ADMIN@Example.COM  ")
    assert_equal "admin@example.com", steward.email
  end

  test "requires first_name" do
    steward = stewards(:one)
    steward.first_name = nil
    assert_not steward.valid?
  end

  test "requires last_name" do
    steward = stewards(:one)
    steward.last_name = nil
    assert_not steward.valid?
  end

  test "full_name" do
    steward = stewards(:one)
    assert_equal "Admin Steward", steward.full_name
  end

  test "authenticate_by with correct credentials" do
    steward = Steward.authenticate_by(email: "admin@ashevillagers.org", password: "password")
    assert_equal stewards(:one), steward
  end

  test "authenticate_by with wrong password" do
    steward = Steward.authenticate_by(email: "admin@ashevillagers.org", password: "wrong")
    assert_nil steward
  end

  test "generates password reset token" do
    steward = stewards(:one)
    token = steward.generate_token_for(:password_reset)
    assert_not_nil token
    assert_equal steward, Steward.find_by_token_for(:password_reset, token)
  end
end
