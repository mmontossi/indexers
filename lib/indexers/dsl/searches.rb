module Indexers
  module Dsl
    class Searches < Api
      include Traitable

      private

      def add_block(name, args, options, &block)
        if %i(functions must must_not should).include?(name)
          child = []
          @parent[name] = child
          continue [], child, &block
        else
          super
        end
      end

      def add_argument(name, args, options)
        if name == :query && args.any?
          indexer = Indexers.definitions.find(args.first)
          hash = self.class.new(indexer, [options], &indexer.searches).to_h
          @parent[name] = hash[:query]
        else
          super
        end
      end

    end
  end
end
