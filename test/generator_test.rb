require 'test_helper'
require 'rails/generators'
require 'generators/indexers/install/install_generator'
require 'generators/indexers/indexer/indexer_generator'

class GeneratorTest < Rails::Generators::TestCase
  destination Rails.root.join('tmp')

  teardown do
    FileUtils.rm_rf destination_root
  end

  test 'install' do
    self.class.tests Indexers::Generators::InstallGenerator
    run_generator
    assert_file 'config/initializers/indexers.rb'
  end

  test 'index' do
    self.class.tests Indexers::Generators::IndexerGenerator
    run_generator %w(products)
    assert_file 'app/indexers/products_indexer.rb'
  end

end
