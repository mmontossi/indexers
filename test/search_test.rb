require 'test_helper'

class SearchTest < ActiveSupport::TestCase

  setup do
    Indexers.reindex
  end

  test 'order' do
    shop = Shop.create
    (1..3).step do |id|
      product = shop.products.create(
        id: id,
        name: id,
        price: id,
        position: id,
        currency: 'UYU'
      )
      product
    end
    sleep 2

    assert_equal [1, 2, 3], Product.search.order(id: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search.order(id: :desc).map(&:id)

    assert_equal [1, 2, 3], Product.search.order(name: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search.order(name: :desc).map(&:id)

    assert_equal [1, 2, 3], Product.search.order(price: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search.order(price: :desc).map(&:id)

    assert_equal [3, 2, 1], Product.search.order(position: :asc).map(&:id)
    assert_equal [3, 2, 1], Product.search.order(position: :desc).map(&:id)
  end

  test 'with and without' do
    (1..3).step do |id|
      shop = Shop.create(id: id)
    end
    Shop.create id: 4
    sleep 2

    assert_equal [4, 3], Shop.search.page(1, length: 2, with: 4).map(&:id)
    assert_equal [4, 2, 1], Shop.search.page(1, without: 3).map(&:id)
  end

  test 'includes' do
    shop = Shop.create
    product = shop.products.create(name: 'Test')
    sleep 2

    product = Product.search.includes(:shop).first
    Shop.expects(:connection).never
    assert_equal shop, product.shop
  end

  test 'pagination' do
    (1..5).step do |id|
      shop = Shop.create(id: id)
    end
    sleep 2

    collection = Shop.search.page(1, length: 2)
    assert_equal 1, collection.first_page
    assert_equal 3, collection.last_page
    assert_equal 3, collection.total_pages
    assert_equal 5, collection.total_count
    assert_equal 1, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 0, collection.padding
    assert_nil collection.previous_page
    assert_equal 2, collection.next_page
    assert_not collection.out_of_bounds?
    assert_equal [5, 4], collection.map(&:id)

    collection = Shop.search.page(2, length: 2)
    assert_equal 1, collection.first_page
    assert_equal 3, collection.last_page
    assert_equal 3, collection.total_pages
    assert_equal 5, collection.total_count
    assert_equal 2, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 0, collection.padding
    assert_equal 1, collection.previous_page
    assert_equal 3, collection.next_page
    assert_not collection.out_of_bounds?
    assert_equal [3, 2], collection.map(&:id)

    collection = Shop.search.page(3, length: 2)
    assert_equal 1, collection.first_page
    assert_equal 3, collection.last_page
    assert_equal 3, collection.total_pages
    assert_equal 5, collection.total_count
    assert_equal 3, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 0, collection.padding
    assert_equal 2, collection.previous_page
    assert_nil collection.next_page
    assert_not collection.out_of_bounds?
    assert_equal [1], collection.map(&:id)

    collection = Shop.search.page(4, length: 2)
    assert_equal 1, collection.first_page
    assert_equal 3, collection.last_page
    assert_equal 3, collection.total_pages
    assert_equal 5, collection.total_count
    assert_equal 4, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 0, collection.padding
    assert_equal 3, collection.previous_page
    assert_nil collection.next_page
    assert collection.out_of_bounds?
    assert_equal [], collection.to_a

    collection = Shop.search.page(1, length: 2, padding: 2)
    assert_equal 1, collection.first_page
    assert_equal 2, collection.last_page
    assert_equal 2, collection.total_pages
    assert_equal 3, collection.total_count
    assert_equal 1, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 2, collection.padding
    assert_nil collection.previous_page
    assert_equal 2, collection.next_page
    assert_not collection.out_of_bounds?
    assert_equal [3, 2], collection.map(&:id)

    collection = Shop.search.page(2, length: 2, padding: 2)
    assert_equal 1, collection.first_page
    assert_equal 2, collection.last_page
    assert_equal 2, collection.total_pages
    assert_equal 3, collection.total_count
    assert_equal 2, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 2, collection.padding
    assert_equal 1, collection.previous_page
    assert_nil collection.next_page
    assert_not collection.out_of_bounds?
    assert_equal [1], collection.map(&:id)

    collection = Shop.search.page(3, length: 2, padding: 2)
    assert_equal 1, collection.first_page
    assert_equal 2, collection.last_page
    assert_equal 2, collection.total_pages
    assert_equal 3, collection.total_count
    assert_equal 3, collection.current_page
    assert_equal 2, collection.page_length
    assert_equal 2, collection.padding
    assert_equal 2, collection.previous_page
    assert_nil collection.next_page
    assert collection.out_of_bounds?
    assert_equal [], collection.to_a
  end

end
