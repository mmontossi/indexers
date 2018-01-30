require 'test_helper'

class IndexersTest < ActiveSupport::TestCase

  test 'namespace' do
    assert_equal 'dummy_test', Indexers.namespace
  end

  test 'indexing' do
    Indexers.unindex
    wait
    assert_not Indexers.exists?

    Indexers.index
    wait
    assert Indexers.exists?

    Indexers.expects(:unindex).once
    Indexers.expects(:index).once
    Indexers.reindex
  end

  test 'settings' do
    hash = Indexers.client.indices.get_settings(index: 'dummy_test').deep_symbolize_keys
    assert_equal(
      Indexers.configuration.settings,
      hash[:dummy_test][:settings][:index].slice(:analysis)
    )
  end

  test 'suggest' do
    shop1 = Shop.create
    shop2 = Shop.create
    product = shop1.products.create(name: 'Les Paul')
    wait

    assert_equal [], Indexers.suggest(:product)
    assert_equal [], Indexers.suggest(:product, 'les', shop: shop2)
    assert_equal(
      [['Les Paul', product]],
      Indexers.suggest(:product, 'les')
    )
    assert_equal(
      [['Les Paul', product]],
      Indexers.suggest(:product, 'les', shop: shop1)
    )
  end

end
