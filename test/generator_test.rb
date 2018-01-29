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
    assert_file 'config/elasticsearch.yml'
  end

  test 'index' do
    self.class.tests Indexers::Generators::IndexerGenerator
    run_generator %w(economy/exchange)
    assert_file 'app/indexers/economy/exchange_indexer.rb'
  end

end
