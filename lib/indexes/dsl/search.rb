module Indexes
  module Dsl
    class Search < Api

      private

      def add_block(name, args, options, &block)
        if %i(functions must must_not should).include?(name)
          child = []
          @parent[name] = child
          self.class.new [], child, &block
        else
          super
        end
      end

      def add_argument(name, args, options)
        if name == :query && args.first.is_a?(Symbol)
          @parent[name] = Indexes.definitions.find(args.first).search([options]).query[:query]
        else
          super
        end
      end

    end
  end
end
