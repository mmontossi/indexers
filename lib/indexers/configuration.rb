module Indexers
  class Configuration

    def mappings(&block)
      if block_given?
        @mappings = Dsl::Api.new(&block).to_h
      else
        @mappings ||= {}
      end
    end

    def analysis(&block)
      if block_given?
        @analysis = { analysis: Dsl::Api.new(&block).to_h }
      else
        @analysis ||= {}
      end
    end

    def suggestions(&block)
      if block_given?
        @suggestions = block
      else
        @suggestions
      end
    end

    def computed_sort(*args, &block)
      Indexers.computed_sorts.add *args, &block
    end

  end
end
