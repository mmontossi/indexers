module Indexes
  class Definitions

    def add(*args)
      index = Index.new(*args)
      registry[index.name] = index
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
