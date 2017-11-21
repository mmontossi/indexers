module Indexers
  class Collection
    include Enumerable

    attr_reader :indexer, :scope, :args, :options

    delegate :model, to: :indexer
    delegate :model_name, to: :model
    delegate :each, :map, :size, :length, :count, :[], :to_a, to: :records

    alias_method :to_ary, :to_a

    def initialize(indexer, scope, args, options)
      @loaded = false
      @indexer = indexer
      @scope = scope
      @args = args
      @options = options
    end

    def includes(*args)
      chain includes: args
    end

    def page(number, options={})
      length = page_option(options, :length, 10)
      padding = page_option(options, :padding, 0)
      current_page = [number.to_i, 1].max
      values = Module.new do
        define_method :page_length do
          length
        end
        define_method :padding do
          padding
        end
        define_method :current_page do
          current_page
        end
      end
      overrides = {
        from: ((length * (current_page - 1)) + padding),
        size: length
      }
      chain Pagination, values, overrides
    end

    def order(options)
      mappings = Indexers.configuration.mappings
      values = []
      options.each do |property, direction|
        order = { order: direction }
        if block = Indexers.computed_sorts.find(property)
          values << { _script: Dsl::Api.new(direction, &block).to_h }
        elsif property == :id
          values << { _uid: order }
        elsif mappings.has_key?(property) && (mappings[property][:type][:fields][:raw] rescue false)
          values << { "#{property}.raw" => order }
        else
          values << { property => order }
        end
      end
      if values.any?
        chain sort: values
      else
        chain
      end
    end

    def response
      if @loaded == true
        @response
      else
        @loaded = true
        @response = indexer.search(query)
      end
    end

    def query
      @query ||= begin
        pagination = options.slice(:from, :size, :sort)
        body = Dsl::Search.new(indexer, args.append(options), &indexer.options[:search]).to_h[:query]
        request = Dsl::Search.new do
          query body
          %i(from size).each do |name|
            if pagination.has_key?(name)
              send name, pagination[name]
            end
          end
          if pagination.has_key?(:sort)
            sort pagination[:sort]
          else
            sort do
              _uid do
                order 'desc'
              end
            end
          end
        end
        request.to_h
      end
    end

    private

    def records
      @records ||= begin
        ids = response['hits']['hits'].map{ |hit| hit['_id'].to_i }
        includes = options.fetch(:includes, [])
        scope.includes(includes).where(id: ids).sort do |a,b|
          ids.index(a.id) <=> ids.index(b.id)
        end
      end
    end

    def page_option(source, name, default)
      source[name] || begin
        if Rails.configuration.cache_classes == false
          Rails.application.eager_load!
        end
        if defined?(Pagers)
          Pagers.configuration.send name
        else
          default
        end
      end
    end

    def chain(*extensions)
      overrides = extensions.extract_options!
      collection = Collection.new(indexer, scope, args, options.merge(overrides))
      extensions.each do |extension|
        collection.extend extension
      end
      collection
    end

  end
end
