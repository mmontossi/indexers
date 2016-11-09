require 'test_helper'

class IndicesTest < ActiveSupport::TestCase

  setup do
    Indices.build
  end

  teardown do
    Indices.destroy
  end

  test 'namespace' do
    assert_equal 'dummy_test', Indices.namespace
  end

  test 'find' do
    assert Indices.find(:products)
  end

  test 'exist' do
    assert Indices.exist?(:products)
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
    Indices.suggest(:products, term, shop: shop).map do |suggestion|
      suggestion[:text]
    end
  end

end
