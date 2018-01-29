module Indexers
  class Base

    def name
      model_name.underscore.gsub '/', '_'
    end

    def model
      model_name.safe_constantize
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
        normalize(
          record,
          index: namespace,
          type: name
        )
      )
    end

    def index(record=nil)
      if record
        client.create(
          normalize(
            record,
            index: namespace,
            type: name,
            body: serialize(record)
          )
        )
      else
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
              { index: normalize(record, data: serialize(record)) }
            end
          )
        end
      end
    end

    def reindex(record=nil)
      if record
        client.bulk(
          index: namespace,
          type: name,
          body: [
            { delete: normalize(record) },
            { index: normalize(record, data: serialize(record)) }
          ]
        )
      else
        unindex
        reindex
      end
    end

    def unindex(record=nil)
      if record
        client.delete(
          normalize(
            record,
            index: namespace,
            type: name
          )
        )
      else
        client.delete(
          index: namespace,
          type: name
        )
      end
    end

    private

    delegate :client, :namespace, :configuration, to: Indexers

    def model_name
      self.class.name.remove 'Indexer'
    end

    def normalize(record, hash={})
      hash[:"#{'_' unless hash.has_key?(:index)}id"] = record.id
      if has_parent?
        hash[:parent] = record.send("#{mappings[:_parent][:type]}_id")
      end
      hash
    end

  end
end
