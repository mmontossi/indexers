require 'test_helper'

class IndexTest < ActiveSupport::TestCase

  setup do
    Indexers.index
  end

  teardown do
    Indexers.unindex
  end

  test 'namespace' do
    assert_equal 'dummy_test', Indexers.namespace
  end

  test 'find' do
    assert Indexers.definitions.find(:product)
  end

  test 'suggest' do
    shop = Shop.create
    ['Les Paul', 'Stratocaster'].each do |name|
      product = shop.products.create(name: name)
      product.run_callbacks :commit
    end
    sleep 2

    assert_equal [], suggest('', shop)
    assert_equal ['Les Paul'], suggest('les', shop)
    assert_equal ['Stratocaster'], suggest('str', shop)
  end

  private

  def suggest(term, shop)
    Indexers.suggest(:product, term, shop: shop).map do |suggestion|
      suggestion[:text]
    end
  end

end
