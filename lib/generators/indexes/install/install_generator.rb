require 'rails/generators'

module Indexes
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      def create_initializer_file
        copy_file 'initializer.rb', 'config/initializers/indexes.rb'
      end

    end
  end
end
