module Configuration::Configurable
  extend ActiveSupport::Concern

  class_methods do
    def configure_with(*names, instance_methods: true, **mappings)
      # Build method_name => config_key mapping
      method_map = {}
      names.each { |name| method_map[name.to_sym] = name.to_sym }
      mappings.each { |method_name, config_key| method_map[method_name.to_sym] = config_key.to_sym }

      config_keys = method_map.values
      attr_names = method_map.keys

      Configuration.expected_names.merge(config_keys.map(&:to_s))

      # Create CurrentConfiguration < ActiveSupport::CurrentAttributes
      # Pre-set the instances key to avoid calling Class#name (which CurrentAttributes
      # uses internally, and which conflicts if :name is declared as an attribute).
      current_config = Class.new(ActiveSupport::CurrentAttributes) do
        @current_instances_key = :"#{object_id}_current_configuration"
        attribute(*attr_names, :_loaded)
      end

      const_set(:CurrentConfiguration, current_config)

      current_config.define_singleton_method(:ensure_loaded) do
        inst = current_config.instance
        return if inst._loaded

        values = Configuration.values_at(*config_keys)
        attr_names.each_with_index do |attr, i|
          inst.send(:"#{attr}=", values[i])
        end
        inst._loaded = true
      end

      # Define class methods
      method_map.each_key do |method_name|
        define_singleton_method(method_name) do
          current_config.ensure_loaded
          current_config.instance.send(method_name)
        end
      end

      # Define instance methods
      if instance_methods
        method_map.each_key do |method_name|
          define_method(method_name) do
            current_config.ensure_loaded
            current_config.instance.send(method_name)
          end
        end
      end

      # Define reload_configuration!
      define_singleton_method(:reload_configuration!) do
        current_config.reset
      end
    end
  end
end
