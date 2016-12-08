module Indexes
  class Index
    include Comparable

    attr_reader :name, :type, :options

    def initialize(name, options={})
      @name = name
      @type = @name.to_s.singularize
      @options = options
      indexify_model
    end

    def mappings
      @mappings ||= Dsl::Mappings.new(&options[:mappings]).to_h
    end

    def model
      (options[:class_name] || type.classify).constantize
    end

    def has_parent?
      mappings.has_key? :_parent
    end

    def <=>(other)
      if has_parent? && other.has_parent?
        0
      elsif other.has_parent?
        1
      else
        -1
      end
    end

    def any?(*args)
      search(*args).count > 0
    end

    def none?(*args)
      !any?(*args)
    end

    def search(*args)
      Collection.new self, *args, &options[:search]
    end

    def raw_search(query)
      client.search(
        index: namespace,
        type: type,
        body: query
      )
    end

    def exists?(record)
      client.exists?(
        with_parent(
          record,
          index: namespace,
          type: type,
          id: record.id
        )
      )
    end

    def index(record)
      client.create(
        with_parent(
          record,
          index: namespace,
          type: type,
          id: record.id,
          body: serialize(record)
        )
      )
    end

    def reindex(record)
      client.bulk(
        index: namespace,
        type: type,
        body: [
          { delete: with_parent(record, _id: record.id) },
          { index: with_parent(record, _id: record.id, data: serialize(record)) }
        ]
      )
    end

    def unindex(record)
      client.delete(
        with_parent(
          record,
          index: namespace,
          type: type,
          id: record.id
        )
      )
    end

    def build
      client.indices.put_mapping(
        index: namespace,
        type: type,
        body: mappings
      )
      model.find_in_batches do |records|
        client.bulk(
          index: namespace,
          type: type,
          body: records.map do |record|
            { index: with_parent(record, _id: record.id, data: serialize(record)) }
          end
        )
      end
    end

    private

    %i(client namespace).each do |name|
      define_method name do
        Indexes.send name
      end
    end

    def with_parent(record, hash)
      if has_parent?
        hash.merge parent: record.send("#{mappings[:_parent][:type].singularize}_id")
      else
        hash
      end
    end

    def serialize(record)
      Dsl::Serialization.new(record, &options[:serialization]).to_h
    end

    def indexify_model
      index = self
      model.include Indexes::Concern
      model.define_singleton_method :index do
        index
      end
    end

  end
end
