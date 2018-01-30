require 'test_helper'

class CollectionTest < ActiveSupport::TestCase

  test 'order' do
    shop = Shop.create
    (1..3).step do |id|
      shop.products.create(
        id: id,
        name: id,
        price: id,
        position: id,
        currency: 'UYU'
      )
    end
    wait

    assert_equal [1, 2, 3], Product.search('').order(id: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search('').order(id: :desc).map(&:id)

    assert_equal [1, 2, 3], Product.search('').order(name: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search('').order(name: :desc).map(&:id)

    assert_equal [1, 2, 3], Product.search('').order(price: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search('').order(price: :desc).map(&:id)

    assert_equal [1, 2, 3], Product.search('').order(position: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search('').order(position: :desc).map(&:id)
  end

  test 'includes' do
    collection = Product.search('').includes(:shop)
    scope = collection.scope
    scope.expects(:includes).with(%i(shop)).returns(scope.dup)
    collection.to_a
  end

  test 'chain' do
    Shop.create
    Shop.create name: 'Andertons'
    wait

    assert_equal 1, Shop.where(name: 'Andertons').search('').count
    assert_equal 2, Shop.search('').count
  end

end
