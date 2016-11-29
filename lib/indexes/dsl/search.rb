module Indexes
  module Dsl
    class Search < Api

      private

      def add_block(name, args, options)
        if %i(functions must must_not should).include?(name)
          @parent[name] = []
        else
          super
        end
      end

      def add_argument(name, args, options)
        if name == :query && args.first.is_a?(Symbol)
          @parent[name] = Indexes[args.first].search(options).query[:query]
        else
          super
        end
      end

    end
  end
end
