module Indexes
  class Proxy

    def initialize(name, options={}, &block)
      @options = options
      instance_eval &block
      Indexes.add name, @options
    end

    %i(mappings serializer search).each do |name|
      define_method name do |&block|
        @options[name] = block
      end
    end

  end
end
