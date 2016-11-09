module Indices
  module Dsl
    class Api

      def initialize(args=[], parent={}, &block)
        @args = args
        @parent = parent
        instance_exec *args, &block
      end

      def method_missing(name, *args, &block)
        options = args.extract_options!
        name = name.to_sym
        if block_given?
          child = add_block(name, args, options)
          continue child, &block
        elsif args.size > 0
          add_argument name, args, options
        elsif options.any?
          add_options name, options
        else
          add_empty name
        end
      end

      def to_h
        @parent
      end

      private

      def add_block(name, args, options)
        case @parent
        when Array
          item = options.merge(name => {})
          @parent << item
          child = item[name]
        when Hash
          if @parent.has_key?(name)
            child = @parent[name].merge!(options)
          else
            child = @parent[name] = {}
          end
        end
        if args.any?
          child[args.first.to_sym] = {}
        else
          child
        end
      end

      def add_argument(name, args, options)
        @parent[name] = args.first
      end

      def add_options(name, options)
        options.symbolize_keys!
        case @parent
        when Array
          @parent << { name => options }
        when Hash
          if @parent.has_key?(name)
            @parent[name].merge! options
          else
            @parent[name] = options
          end
        end
      end

      def add_empty(name)
        case @parent
        when Array
          @parent << { name => {} }
        when Hash
          @parent[name] = {}
        end
      end

      def continue(child, &block)
        self.class.new @args, child, &block
      end

    end
  end
end
