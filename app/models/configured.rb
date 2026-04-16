module Configured
  include Configuration::Configurable

  configure_with :openai_api_key

  def self.RubyLLM
    RubyLLM.config.openai_api_key = openai_api_key
    RubyLLM
  end
end
