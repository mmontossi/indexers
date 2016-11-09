require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  setup do
    Indices.build
  end

  teardown do
    Indices.destroy
  end

  test 'indexing' do
    shop = Shop.create(name: 'Anderstons')
    product = shop.products.create(name: 'Les Paul', category: 'Gibson')
    product.run_callbacks :commit
    sleep 2

    assert_equal 1, Product.search.count
    product.destroy
    product.run_callbacks :commit
    assert_equal 0, Product.search.count
  end

end
