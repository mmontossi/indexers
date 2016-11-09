module Indices
  class Collection
    include Enumerable

    delegate :model, to: :index
    delegate :model_name, to: :model
    delegate :each, :map, :size, :length, :count, :[], :to_a, to: :records

    alias_method :to_ary, :to_a

    def initialize(index, *args, &block)
      @loaded = false
      @index = index
      @options = args.extract_options!
      @args = args
      @block = block
    end

    def page(number, options={})
      length = (fetch_option(options, :length) || 10)
      padding = (fetch_option(options, :padding) || 0)
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
      mappings = Indices.configuration.mappings
      sort = []
      options.each do |property, direction|
        if block = Indices.configuration.computed_sorts[property]
          sort << Dsl::Api.new(direction, &block).to_h
        elsif property == :id
          sort << { _uid: { order: direction } }
        elsif mappings.has_key?(property) && mappings[property][:type] == 'string'
          sort << { "#{property}.raw" => { order: direction } }
        end
      end
      if sort.any?
        chain sort: sort
      else
        chain
      end
    end

    def response
      if @loaded == true
        @response
      else
        @loaded = true
        @response = index.raw_search(query)
      end
    end

    def query
      @query ||= begin
        pagination = options.slice(:from, :size, :sort)
        without_ids = fetch_ids(options[:without])
        body = Dsl::Search.new(args.append(options), &block).to_h[:query]
        request = Dsl::Search.new do
          if without_ids.any?
            query do
              filtered do
                filter do
                  bool do
                    must_not do
                      without_ids.each do |id|
                        term do
                          _id id
                        end
                      end
                    end
                  end
                end
                query body
              end
            end
          else
            query body
          end
          %i(from size).each do |option|
            if pagination.has_key?(option)
              send option, pagination[option]
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

    attr_reader :index, :args, :options, :block

    def records
      @records ||= begin
        if missing_ids.any?
          last_index = -(missing_ids.length + 1)
          ids = (missing_ids.sort.reverse + hit_ids.to(last_index))
        else
          ids = hit_ids
        end
        index.model.includes(includes).where(id: ids).sort do |a,b|
          ids.index(a.id) <=> ids.index(b.id)
        end
      end
    end

    def with_ids
      @with_ids ||= fetch_ids(options[:with])
    end

    def hit_ids
      @hit_ids ||= response['hits']['hits'].map{ |hit| hit['_id'].to_i }
    end

    def missing_ids
      @missing_ids ||= (with_ids - hit_ids)
    end

    def includes
      @inclues ||= begin
        if options.has_key?(:includes)
          Array options[:includes]
        else
          []
        end
      end
    end

    def fetch_option(options, name)
      options[name] || begin
        if Rails.configuration.cache_classes == false
          Rails.application.eager_load!
        end
        if defined?(Pagers)
          Pagers.config[name]
        end
      end
    end

    def fetch_ids(source)
      case source
      when Fixnum,String
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
      Collection.new(index, *args.append(options.merge(overrides)), &block).tap do |collection|
        extensions.each do |extension|
          collection.extend extension
        end
      end
    end

  end
end
