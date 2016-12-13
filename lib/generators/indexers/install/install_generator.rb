require 'rails/generators'

module Indexers
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      def create_initializer_file
        copy_file 'initializer.rb', 'config/initializers/indexers.rb'
      end

      def create_configuration_file
        copy_file 'configuration.yml', 'config/elasticsearch.yml'
      end

    end
  end
end
