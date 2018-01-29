require 'rails/generators'

module Indexers
  module Generators
    class IndexerGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def create_index_file
        template 'indexer.rb', File.join('app/indexers', class_path, "#{file_name}_indexer.rb")
      end

    end
  end
end
