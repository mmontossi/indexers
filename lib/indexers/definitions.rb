module Indexers
  class Definitions

    def add(*args)
      indexer = Indexer.new(*args)
      registry[indexer.name] = indexer
    end

    def find(name)
      registry[name]
    end

    def each(&block)
      registry.values.sort.each &block
    end

    private

    def registry
      @registry ||= {}
    end

  end
end
