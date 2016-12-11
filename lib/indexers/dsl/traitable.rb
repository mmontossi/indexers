module Indexers
  module Dsl
    module Traitable
      extend ActiveSupport::Concern

      def initialize(indexer=nil, args=[], parent={}, binding=nil, &block)
        @indexer = indexer
        @binding = binding
        @block = block
        super args, parent, &block
      end

      def traits(*names)
        if @indexer
          @binding = @block.binding
          names.each do |name|
            instance_eval &@indexer.options[:traits][name]
          end
          @binding = nil
        end
      end

      def method_missing(name, *args, &block)
        if args.size == 0 && !block_given? && @binding.try(:local_variable_defined?, name)
          @binding.local_variable_get name
        else
          super
        end
      end

      private

      def continue(args, parent, &block)
        self.class.new @indexer, args, parent, @binding, &block
      end

    end
  end
end
