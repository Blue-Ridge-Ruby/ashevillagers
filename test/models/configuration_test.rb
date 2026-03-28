require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  # -- Validations --

  test "valid with name and value" do
    config = Configuration.new(name: "something", value: "val")
    assert config.valid?
  end

  test "invalid without name" do
    config = Configuration.new(name: nil, value: "val")
    assert_not config.valid?
  end

  test "invalid with duplicate name" do
    assert_not Configuration.new(name: configurations(:site_name).name, value: "x").valid?
  end

  test "valid with nil value" do
    config = Configuration.new(name: "nullable_setting")
    assert config.valid?
  end

  # -- [] --

  test "[] returns value for existing name" do
    assert_equal "Ashevillagers", Configuration[:site_name]
  end

  test "[] returns nil for missing name" do
    assert_nil Configuration[:nonexistent]
  end

  test "[] returns nil when value is stored as nil" do
    Configuration.create!(name: "nil_val", value: nil)
    assert_nil Configuration[:nil_val]
  end

  # -- fetch --

  test "fetch returns value for existing name" do
    assert_equal "Ashevillagers", Configuration.fetch(:site_name)
  end

  test "fetch raises KeyError for missing name with no default" do
    assert_raises(KeyError) { Configuration.fetch(:nonexistent) }
  end

  test "fetch returns default when given for missing name" do
    assert_equal "fallback", Configuration.fetch(:nonexistent, "fallback")
  end

  test "fetch yields to block for missing name" do
    result = Configuration.fetch(:nonexistent) { |name| "missing: #{name}" }
    assert_equal "missing: nonexistent", result
  end

  test "fetch returns nil value for existing key with nil value" do
    Configuration.create!(name: "nil_val", value: nil)
    assert_nil Configuration.fetch(:nil_val)
  end

  test "fetch raises ArgumentError with too many arguments" do
    assert_raises(ArgumentError) { Configuration.fetch(:x, "a", "b") }
  end

  # -- values_at --

  test "values_at returns values in order, nil for missing" do
    result = Configuration.values_at(:site_name, :nonexistent, :max_attendees)
    assert_equal ["Ashevillagers", nil, "500"], result
  end

  test "values_at makes a single query" do
    queries = count_queries { Configuration.values_at(:site_name, :max_attendees) }
    assert_equal 1, queries
  end

  # -- fetch_values --

  test "fetch_values returns values in order" do
    result = Configuration.fetch_values(:site_name, :max_attendees)
    assert_equal ["Ashevillagers", "500"], result
  end

  test "fetch_values raises KeyError for missing name" do
    assert_raises(KeyError) { Configuration.fetch_values(:site_name, :nonexistent) }
  end

  test "fetch_values yields to block for missing name" do
    result = Configuration.fetch_values(:site_name, :nonexistent) { |n| "default_#{n}" }
    assert_equal ["Ashevillagers", "default_nonexistent"], result
  end

  test "fetch_values makes a single query" do
    queries = count_queries { Configuration.fetch_values(:site_name, :max_attendees) }
    assert_equal 1, queries
  end

  # -- each_pair --

  test "each_pair yields name-value pairs" do
    pairs = {}
    Configuration.each_pair { |name, value| pairs[name] = value }
    assert_equal "Ashevillagers", pairs["site_name"]
    assert_equal "500", pairs["max_attendees"]
  end

  test "each_pair returns enumerator without block" do
    assert_kind_of Enumerator, Configuration.each_pair
  end

  # -- to_h / to_hash --

  test "to_h returns hash of all configurations" do
    h = Configuration.to_h
    assert_equal "Ashevillagers", h["site_name"]
    assert_equal "500", h["max_attendees"]
  end

  test "to_hash returns same as to_h" do
    assert_equal Configuration.to_h, Configuration.to_hash
  end

  # -- all_and_expected --

  test "all_and_expected includes persisted configurations" do
    results = Configuration.all_and_expected
    names = results.map(&:name)
    assert_includes names, "site_name"
    assert_includes names, "max_attendees"
  end

  test "all_and_expected includes expected but missing configurations as new records" do
    results = Configuration.all_and_expected
    tito_slug = results.find { |c| c.name == "tito_account_slug" }
    assert_not_nil tito_slug
    assert_not tito_slug.persisted?
  end

  test "all_and_expected does not duplicate existing expected names" do
    Configuration.create!(name: "tito_account_slug", value: "demo")
    results = Configuration.all_and_expected
    matches = results.select { |c| c.name == "tito_account_slug" }
    assert_equal 1, matches.size
    assert matches.first.persisted?
  end

  test "all_and_expected is sorted by name" do
    results = Configuration.all_and_expected
    names = results.map(&:name)
    assert_equal names.sort, names
  end

  # -- secret? --

  test "secret? is true when name contains key" do
    assert Configuration.new(name: "tito_api_key").secret?
  end

  test "secret? is true when name contains secret" do
    assert Configuration.new(name: "webhook_secret").secret?
  end

  test "secret? is true when name contains token" do
    assert Configuration.new(name: "access_token").secret?
  end

  test "secret? is case insensitive" do
    assert Configuration.new(name: "API_KEY").secret?
    assert Configuration.new(name: "Access_Token").secret?
  end

  test "secret? is false for non-secret names" do
    assert_not Configuration.new(name: "site_name").secret?
    assert_not Configuration.new(name: "max_attendees").secret?
  end

  test "secret? requires word boundary match" do
    assert_not Configuration.new(name: "keyboard_layout").secret?
    assert_not Configuration.new(name: "monkey_patch").secret?
  end

  # -- display_value --

  test "display_value masks secret values except last 4 chars" do
    config = Configuration.new(name: "api_key", value: "sk_live_abc123xyz")
    assert_equal "*************3xyz", config.display_value
  end

  test "display_value returns full value for non-secrets" do
    config = Configuration.new(name: "site_name", value: "Ashevillagers")
    assert_equal "Ashevillagers", config.display_value
  end

  test "display_value returns short secret values unmasked" do
    config = Configuration.new(name: "api_key", value: "abcd")
    assert_equal "abcd", config.display_value
  end

  test "display_value handles nil value for secrets" do
    config = Configuration.new(name: "api_key", value: nil)
    assert_nil config.display_value
  end

  private

  def count_queries(&block)
    count = 0
    counter = ->(_name, _started, _finished, _unique_id, payload) {
      count += 1 unless payload[:name] == "SCHEMA" || payload[:cached]
    }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end
end
