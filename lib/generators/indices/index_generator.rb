require 'rails/generators'

module Indices
  module Generators
    class IndexGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def create_index_file
        template 'index.rb', "app/indices/#{table_name}_index.rb"
      end

    end
  end
end
