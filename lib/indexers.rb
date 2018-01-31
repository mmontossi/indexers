require 'indexers/extensions/active_record/base'
require 'indexers/base'
require 'indexers/collection'
require 'indexers/concern'
require 'indexers/configuration'
require 'indexers/pagination'
require 'indexers/railtie'
require 'indexers/version'

module Indexers
  class << self

    def namespace
      "#{Rails.application.class.parent_name}_#{Rails.env}".downcase
    end

    def client
      @client ||= begin
        require 'elasticsearch'
        config = YAML.load_file("#{Rails.root}/config/elasticsearch.yml")[Rails.env]
        Elasticsearch::Client.new config.deep_symbolize_keys
      end
    end

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def exists?
      client.indices.exists? index: namespace
    end

    def all
      base = "#{Rails.root}/app/indexers"
      indexers = []
      Dir["#{base}/**/*_indexer.rb"].map do |path|
        indexer = path.remove(base, '.rb').camelize.constantize.new
        if indexer.model
          indexers << indexer
        end
      end
      indexers.sort
    end

    def index
      client.indices.create(
        index: namespace,
        body: { settings: configuration.settings }
      )
      all.each &:index
    end

    def reindex
      unindex
      index
    end

    def unindex
      client.indices.delete index: namespace
    end

    def flush
      attempts = 3
      begin
        client.delete_by_query index: namespace
      rescue Elasticsearch::Transport::Transport::Errors::Conflict => exception
        # https://github.com/elastic/elasticsearch-rails/issues/598
        attempts -= 1
        raise exception if attempts.zero?
        sleep 1
        flush
      end
    end

    def suggest(name, *args)
      suggestion = configuration.suggestions[name].call(*args)
      query = { suggest: { all: suggestion } }
      response = client.search(index: namespace, body: query)
      options = response['suggest']['all'].first['options'].map do |option|
        id = option['_id'].to_i
        type = option['_type'].classify.remove('Indexer')
        [option['text'], id, type]
      end
      matches = []
      options.group_by(&:third).each do |type, group|
        ids = group.map(&:second)
        model = type.constantize
        records = model.where(id: ids).to_a.group_by(&:id)
        group.each do |text, id|
          matches << [text, records[id].first]
        end
      end
      matches
    end

  end
end
