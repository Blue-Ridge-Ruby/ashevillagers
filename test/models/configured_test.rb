require "test_helper"

class ConfiguredTest < ActiveSupport::TestCase
  setup do
    Configuration.create!(name: "openai_api_key", value: "sk-test-123")
    Configured.reload_configuration!
  end

  teardown do
    Configuration.find_by(name: "openai_api_key")&.destroy
    Configured.reload_configuration!
  end

  test "openai_api_key reads from Configuration" do
    assert_equal "sk-test-123", Configured.openai_api_key
  end

  test "RubyLLM returns the RubyLLM module" do
    assert_equal RubyLLM, Configured.RubyLLM
  end

  test "RubyLLM sets the openai_api_key on RubyLLM config" do
    Configured.RubyLLM
    assert_equal "sk-test-123", RubyLLM.config.openai_api_key
  end

  test "RubyLLM reflects updated config after reload" do
    Configuration.find_by(name: "openai_api_key").update!(value: "sk-new-456")
    Configured.reload_configuration!

    Configured.RubyLLM
    assert_equal "sk-new-456", RubyLLM.config.openai_api_key
  end

  test "registers openai_api_key as an expected configuration name" do
    assert_includes Configuration.expected_names, "openai_api_key"
  end
end
