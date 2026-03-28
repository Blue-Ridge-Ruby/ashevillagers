require "test_helper"

class Configuration::ConfigurableTest < ActiveSupport::TestCase
  # -- Positional args form: configure_with :foo, :bar --

  test "defines class methods that read from Configuration" do
    klass = new_configurable_class do
      configure_with :site_name, :max_attendees
    end

    assert_equal "Ashevillagers", klass.site_name
    assert_equal "500", klass.max_attendees
  end

  test "defines instance methods by default" do
    klass = new_configurable_class do
      configure_with :site_name
    end

    assert_equal "Ashevillagers", klass.new.site_name
  end

  test "skips instance methods with instance_methods: false" do
    klass = new_configurable_class do
      configure_with :site_name, instance_methods: false
    end

    assert_equal "Ashevillagers", klass.site_name
    assert_not klass.new.respond_to?(:site_name)
  end

  # -- Keyword args form: configure_with custom_name: :config_key --

  test "keyword args define methods with custom names" do
    klass = new_configurable_class do
      configure_with name: :site_name, capacity: :max_attendees
    end

    assert_equal "Ashevillagers", klass.name
    assert_equal "500", klass.capacity
    assert_equal "Ashevillagers", klass.new.name
    assert_equal "500", klass.new.capacity
  end

  # -- Mixed form --

  test "positional and keyword args can be mixed" do
    klass = new_configurable_class do
      configure_with :site_name, capacity: :max_attendees
    end

    assert_equal "Ashevillagers", klass.site_name
    assert_equal "500", klass.capacity
  end

  # -- Loads all at once --

  test "loads all configured values in a single query on first access" do
    klass = new_configurable_class do
      configure_with :site_name, :max_attendees
    end

    klass.reload_configuration!

    queries = count_queries do
      klass.site_name
      klass.max_attendees
    end

    assert_equal 1, queries
  end

  test "returns nil for missing configuration keys" do
    klass = new_configurable_class do
      configure_with :nonexistent_setting
    end

    assert_nil klass.nonexistent_setting
  end

  # -- CurrentConfiguration class --

  test "creates a CurrentConfiguration class on the including class" do
    klass = new_configurable_class do
      configure_with :site_name
    end

    assert klass.const_defined?(:CurrentConfiguration)
    assert klass::CurrentConfiguration < ActiveSupport::CurrentAttributes
  end

  # -- expected_names --

  test "configure_with registers config keys in Configuration.expected_names" do
    new_configurable_class do
      configure_with :site_name, :max_attendees
    end

    assert_includes Configuration.expected_names, "site_name"
    assert_includes Configuration.expected_names, "max_attendees"
  end

  test "keyword-mapped config keys are registered in expected_names" do
    new_configurable_class do
      configure_with capacity: :max_attendees
    end

    assert_includes Configuration.expected_names, "max_attendees"
  end

  test "expected_names accumulates across multiple classes" do
    new_configurable_class { configure_with :site_name }
    new_configurable_class { configure_with :max_attendees }

    assert_includes Configuration.expected_names, "site_name"
    assert_includes Configuration.expected_names, "max_attendees"
  end

  # -- reload_configuration! --

  test "reload_configuration! causes values to be refetched" do
    klass = new_configurable_class do
      configure_with :site_name
    end

    assert_equal "Ashevillagers", klass.site_name

    Configuration.find_by(name: "site_name").update!(value: "New Name")
    klass.reload_configuration!

    assert_equal "New Name", klass.site_name
  ensure
    Configuration.find_by(name: "site_name").update!(value: "Ashevillagers")
  end

  test "reload_configuration! without prior access does not error" do
    klass = new_configurable_class do
      configure_with :site_name
    end

    assert_nothing_raised { klass.reload_configuration! }
  end

  private

  def new_configurable_class(&block)
    Class.new do
      include Configuration::Configurable

      class_eval(&block)
    end
  end

  def count_queries(&block)
    count = 0
    counter = ->(_name, _started, _finished, _unique_id, payload) {
      count += 1 unless payload[:name] == "SCHEMA" || payload[:cached]
    }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end
end
