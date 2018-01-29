module Indexers
  class Configuration

    attr_writer :properties, :settings

    %w(properties settings suggestions computed_sorts).each do |name|
      define_method name do
        variable = "@#{name}"
        instance_variable_get(variable) ||
        instance_variable_set(variable, {})
      end
    end

    %w(suggestions computed_sorts).each do |name|
      define_method name.singularize do |key, &block|
        send(name)[key] = block
      end
    end

  end
end
