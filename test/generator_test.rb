require 'test_helper'
require 'rails/generators'
require 'generators/indexes/install/install_generator'
require 'generators/index/index_generator'

class GeneratorTest < Rails::Generators::TestCase
  destination Rails.root.join('tmp')

  teardown do
    FileUtils.rm_rf destination_root
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
