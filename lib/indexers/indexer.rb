module Indexers
  class Indexer

    attr_reader :name, :mappings, :serialization, :searches, :traits, :options

    def initialize(name, mappings, serialization, searches, traits, options)
      @name = name
      @mappings = mappings
      @serialization = serialization
      @searches = searches
      @traits = traits
      @options = options
    end

    def model
      options.fetch(:class_name, name.to_s.classify).constantize
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

    def search(query)
      client.search(
        index: namespace,
        type: name,
        body: query
      )
    end

    def exists?(record)
      client.exists?(
        with_parent(
          record,
          index: namespace,
          type: name,
          id: record.id
        )
      )
    end

    def index(record)
      client.create(
        with_parent(
          record,
          index: namespace,
          type: name,
          id: record.id,
          body: serialize(record)
        )
      )
    end

    def reindex(record)
      client.bulk(
        index: namespace,
        type: name,
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
          type: name,
          id: record.id
        )
      )
    end

    def build
      client.indices.put_mapping(
        index: namespace,
        type: name,
        body: mappings
      )
      model.find_in_batches do |records|
        client.bulk(
          index: namespace,
          type: name,
          body: records.map do |record|
            { index: with_parent(record, _id: record.id, data: serialize(record)) }
          end
        )
      end
    end

    private

    %i(client namespace).each do |name|
      define_method name do
        Indexers.send name
      end
    end

    def with_parent(record, hash)
      if has_parent?
        hash.merge parent: record.send("#{mappings[:_parent][:type]}_id")
      else
        hash
      end
    end

    def serialize(record)
      Dsl::Serialization.new(self, record, &serialization).to_h
    end

  end
end
