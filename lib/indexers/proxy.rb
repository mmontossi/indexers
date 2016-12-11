module Indexers
  class Proxy

    def initialize(name, options={}, &block)
      @mappings = {}
      @serialization = {}
      @searches = {}
      @traits = {}
      @options = options
      instance_eval &block
      Indexers.definitions.add(
        name,
        @mappings,
        @serialization,
        @searches,
        @traits,
        @options
      )
    end

    %i(serialization searches).each do |name|
      define_method name do |&block|
        instance_variable_set "@#{name}", block
      end
    end

    def mappings(&block)
      @mappings = Dsl::Mappings.new(&block).to_h
    end

    def trait(name, &block)
      @traits[name] = block
    end

  end
end
