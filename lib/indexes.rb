require 'indexes/dsl/api'
require 'indexes/dsl/mappings'
require 'indexes/dsl/search'
require 'indexes/dsl/serialization'
require 'indexes/collection'
require 'indexes/concern'
require 'indexes/configuration'
require 'indexes/definitions'
require 'indexes/index'
require 'indexes/pagination'
require 'indexes/proxy'
require 'indexes/railtie'
require 'indexes/version'

module Indexes
  class << self

    delegate :any?, :none?, to: :registry

    def namespace
      "#{Rails.application.class.parent_name} #{Rails.env}".parameterize('_')
    end

    def client
      @client ||= begin
        require 'elasticsearch'
        Elasticsearch::Client.new(
          hosts: configuration.hosts,
          log: configuration.log,
          trace: configuration.trace
        )
      end
    end

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def definitions
      @definitions ||= Definitions.new
    end

    def define(*args, &block)
      Proxy.new *args, &block
    end

    def build
      unless client.indices.exists?(index: namespace)
        client.indices.create(
          index: namespace,
          body: { settings: configuration.analysis }
        )
      end
      definitions.each &:build
    end

    def rebuild
      destroy
      build
    end

    def exist?(type)
      client.indices.exists? index: namespace, type: type
    end

    def destroy
      if client.indices.exists?(index: namespace)
        client.indices.delete index: namespace
      end
    end

    def suggest(*args)
      response = client.suggest(
        index: namespace,
        body: { suggestions: Dsl::Api.new(args, &configuration.suggestions).to_h }
      )
      response['suggestions'].first['options'].map &:symbolize_keys
    end

  end
end
