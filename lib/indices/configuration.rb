module Indices
  class Configuration

    attr_accessor :hosts, :log, :trace

    def computed_sorts
      @computed_sorts ||= {}
    end

    def mappings(&block)
      if block_given?
        @mappings = Dsl::Mappings.new(&block).to_h
      else
        @mappings
      end
    end

    def analysis(&block)
      if block_given?
        @analysis = { analysis: Dsl::Api.new(&block).to_h }
      else
        @analysis
      end
    end

    def suggestions(&block)
      if block_given?
        @suggestions = block
      else
        @suggestions
      end
    end

    def add_computed_sort(name, &block)
      self.computed_sorts[name] = block
    end

  end
end
