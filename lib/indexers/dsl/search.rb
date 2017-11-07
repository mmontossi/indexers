module Indexers
  module Dsl
    class Search < Traitable

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
        if name == :query && args.first.try(:is_a?, Symbol)
          indexer = Indexers.definitions.find(args.first)
          hash = self.class.new(indexer, [options], &indexer.options[:search]).to_h
          @parent[name] = hash[:query]
        else
          super
        end
      end

    end
  end
end
