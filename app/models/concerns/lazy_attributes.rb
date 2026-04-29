module LazyAttributes
  extend ActiveSupport::Concern

  class_methods do
    # Lazily compute and persist an attribute the first time it's read.
    #
    #   lazy_attribute :animal, -> { (Animal.all - taken).sample }
    #
    # On read: if the column is blank, the proc is instance_exec'd, the result
    # is assigned, and the record is saved (only if persisted and the value
    # actually changed).
    def lazy_attribute(name, generator)
      define_method("ensure_#{name}") do
        attributes[name.to_s].presence || begin
          new_value = instance_exec(&generator)
          public_send("#{name}=", new_value)
          new_value
        end
      end

      define_method(name) do
        v = public_send("ensure_#{name}")
        save if persisted? && public_send("#{name}_changed?")
        v
      end
    end
  end
end
