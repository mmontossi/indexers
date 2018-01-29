require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  test 'indexing' do
    shop = Shop.create(name: 'Anderstons')
    product = shop.products.create(name: 'Les Paul', category: 'Gibson')
    wait

    assert_equal 1, Product.search('').count
    product.destroy
    assert_equal 0, Product.search('').count
  end

end
