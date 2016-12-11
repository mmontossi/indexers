module Indexers
  class Proxy

    def initialize(name, options={}, &block)
      @name = name
      @options = options.merge(traits: {})
      instance_eval &block
      Indexers.definitions.add name, @options
    end

    %i(mappings serialize search).each do |name|
      define_method name do |&block|
        @options[name] = block
      end
    end

    def trait(name, &block)
      @options[:traits][name] = block
    end

  end
end
