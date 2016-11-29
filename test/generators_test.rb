require 'test_helper'
require 'rails/generators'
require 'generators/indexes/install_generator'
require 'generators/indexes/index_generator'

class GeneratorsTest < Rails::Generators::TestCase
  destination File.expand_path('../tmp', File.dirname(__FILE__))

  teardown do
    FileUtils.rm_rf self.destination_root
  end

  test 'install' do
    self.class.tests Indexes::Generators::InstallGenerator
    run_generator
    assert_file 'config/initializers/indexes.rb'
  end

  test 'index' do
    self.class.tests Indexes::Generators::IndexGenerator
    run_generator %w(products)
    assert_file 'app/indexes/products_index.rb'
  end

end
