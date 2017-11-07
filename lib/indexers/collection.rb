module Indexers
  class Collection
    include Enumerable

    attr_reader :indexer, :args, :options

    delegate :model, to: :indexer
    delegate :model_name, to: :model
    delegate :each, :map, :size, :length, :count, :[], :to_a, to: :records

    alias_method :to_ary, :to_a

    def initialize(indexer, args, options)
      @loaded = false
      @indexer = indexer
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
      %i(with without).each do |name|
        if options.has_key?(name)
          overrides[name] = options[name]
        end
      end
      chain Pagination, values, overrides
    end

    def order(options)
      mappings = Indexers.configuration.mappings
      values = []
      options.each do |property, direction|
        if block = Indexers.computed_sorts.find(property)
          values << { _script: Dsl::Api.new(direction, &block).to_h }
        elsif property == :id
          values << { _uid: { order: direction } }
        elsif mappings.has_key?(property) && mappings[property][:type] == 'string'
          values << { "#{property}.raw" => { order: direction } }
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
        without_ids = fetch_ids(options[:without])
        body = Dsl::Search.new(indexer, args.append(options), &indexer.options[:search]).to_h[:query]
        request = Dsl::Search.new do
          if without_ids.any?
            query do
              bool do
                must do
                  body
                end
                must_not do
                  without_ids.each do |id|
                    term do
                      _id id
                    end
                  end
                end
              end
            end
          else
            query body
          end
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
        hit_ids = response['hits']['hits'].map{ |hit| hit['_id'].to_i }
        missing_ids = (fetch_ids(options[:with]) - hit_ids)
        if missing_ids.any?
          last_index = -(missing_ids.length + 1)
          ids = (missing_ids.sort.reverse + hit_ids.to(last_index))
        else
          ids = hit_ids
        end
        includes = options.fetch(:includes, [])
        indexer.model.includes(includes).where(id: ids).sort do |a,b|
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

    def fetch_ids(source)
      case source
      when Integer,String
        [source.to_i]
      when ActiveRecord::Base
        [source.id]
      when ActiveRecord::Relation
        source.ids
      when Array
        source.map{ |value| fetch_ids(value) }.flatten
      else
        []
      end
    end

    def chain(*extensions)
      overrides = extensions.extract_options!
      collection = Collection.new(indexer, args, options.merge(overrides))
      extensions.each do |extension|
        collection.extend extension
      end
      collection
    end

  end
end
