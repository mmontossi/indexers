module Indexes
  module Dsl
    class Api

      def initialize(args=[], parent={}, &block)
        @parent = parent
        instance_exec *args, &block
      end

      def method_missing(name, *args, &block)
        options = args.extract_options!
        name = name.to_sym
        if block_given?
          add_block name, args, options, &block
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

      def add_block(name, args, options, &block)
        case args.first
        when String,Symbol
          child = {}
          node = { args.first.to_sym => child }
        when Enumerable
          child = node = []
        else
          child = node = {}
        end
        case @parent
        when Array
          @parent << options.merge(name => node)
        when Hash
          @parent[name] = node
        end
        case args.first
        when Enumerable
          args.first.each do |arg|
            self.class.new [arg], child, &block
          end
        else
          self.class.new [], child, &block
        end
      end

      def add_argument(name, args, options)
        case @parent
        when Array
          @parent << { name => args.first }
        when Hash
          @parent[name] = args.first
        end
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

    end
  end
end
