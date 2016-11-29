require 'rails/generators'

module Indexes
  module Generators
    class IndexGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def create_index_file
        template 'index.rb', "app/indexes/#{table_name}_index.rb"
      end

    end
  end
end
