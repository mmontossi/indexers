module Indexers
  class Collection
    include Enumerable

    attr_reader :indexer, :scope, :args, :options

    delegate :model, to: :indexer
    delegate :model_name, to: :model
    delegate :each, :size, :length, :to_ary, to: :records

    def initialize(indexer, scope, args, options)
      @indexer = indexer
      @scope = scope
      @args = args
      @options = options
    end

    def includes(*args)
      chain includes: args
    end

    def order(hash)
      sort = []
      hash.each do |property, direction|
        order = { order: direction }
        if property == :id
          sort << { _uid: order }
        elsif block = configuration.computed_sorts[property]
          sort << { _script: block.call(direction) }
        elsif !(configuration.properties[property][:fields][:raw] rescue nil).nil?
          sort << { "#{property}.raw" => order }
        else
          sort << { property => order }
        end
      end
      if sort.any?
        chain sort: sort
      else
        chain
      end
    end

    def page(number, options={})
      length = page_option(options, :length, 10)
      padding = page_option(options, :padding, 0)
      current_page = [number, 1].max
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

    private

    delegate :configuration, to: Indexers

    def records
      @records ||= begin
        ids = response['hits']['hits'].map do |hit|
          hit['_id'].to_i
        end
        includes = internals.fetch(:includes, [])
        scope.includes(includes).where(id: ids).sort do |a, b|
          ids.index(a.id) <=> ids.index(b.id)
        end
      end
    end

    def response
      @response ||= begin
        hash = indexer.query(*args.append(options))
        hash.merge! internals.slice(:from, :size)
        hash[:sort] = internals.fetch(:sort, _uid: { order: 'desc' })
        indexer.search(hash)
      end
    end

    def internals
      @internals ||= options.extract!(:from, :size, :sort, :includes)
    end

    def page_option(options, name, default)
      options[name] || begin
        if defined?(Pagers)
          Pagers.configuration.send name
        else
          default
        end
      end
    end

    def chain(*extensions)
      overrides = extensions.extract_options!
      collection = Collection.new(
        indexer,
        scope,
        args,
        options.merge(overrides)
      )
      extensions.each do |extension|
        collection.extend extension
      end
      collection
    end

  end
end
