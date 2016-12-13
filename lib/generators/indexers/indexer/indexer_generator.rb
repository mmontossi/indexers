require 'rails/generators'

module Indexers
  module Generators
    class IndexerGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def create_index_file
        template 'indexer.rb', File.join('app/indexers', class_path, "#{file_name}_indexer.rb")
      end

      private

      def class_name_option
        if class_path.any?
          ", class_name: '#{class_name}'"
        end
      end

    end
  end
end
