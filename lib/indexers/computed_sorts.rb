module Indexers
  class ComputedSorts

    def add(name, &block)
      registry[name] = block
    end

    def find(name)
      registry[name]
    end

    private

    def registry
      @registry ||= {}
    end

  end
end
