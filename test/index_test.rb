require 'test_helper'

class IndexTest < ActiveSupport::TestCase

  test 'namespace' do
    assert_equal 'dummy_test', Indexers.namespace
  end

  test 'suggest' do
    shop = Shop.create
    ['Les Paul', 'Stratocaster'].each do |name|
      product = shop.products.create(name: name)
    end
    wait

    assert_equal [], suggest('', shop)
    assert_equal ['Les Paul'], suggest('les', shop)
    assert_equal ['Stratocaster'], suggest('str', shop)
  end

  private

  def suggest(term, shop)
    Indexers.suggest(:product, term, shop: shop).map(&:first)
  end

end
