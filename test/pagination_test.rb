require 'test_helper'

class PaginationTest < ActiveSupport::TestCase

  test 'empty' do
    shops = Shop.search('').page(1, length: 2)

    assert_equal 1, shops.total_pages
    assert_equal 1, shops.current_page
    assert_equal 1, shops.first_page
    assert_nil shops.previous_page
    assert_nil shops.next_page
    assert_equal 1, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [], shops.map(&:id)
  end

  test 'first' do
    (1..5).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(1, length: 2)

    assert_equal 3, shops.total_pages
    assert_equal 1, shops.current_page
    assert_equal 1, shops.first_page
    assert_nil shops.previous_page
    assert_equal 2, shops.next_page
    assert_equal 3, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [5, 4], shops.map(&:id)
  end

  test 'middle' do
    (1..5).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(2, length: 2)

    assert_equal 3, shops.total_pages
    assert_equal 2, shops.current_page
    assert_equal 1, shops.first_page
    assert_equal 1, shops.previous_page
    assert_equal 3, shops.next_page
    assert_equal 3, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [3, 2], shops.map(&:id)
  end

  test 'last' do
    (1..5).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(3, length: 2)

    assert_equal 3, shops.total_pages
    assert_equal 3, shops.current_page
    assert_equal 1, shops.first_page
    assert_equal 2, shops.previous_page
    assert_nil shops.next_page
    assert_equal 3, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [1], shops.map(&:id)
  end

  test 'out' do
    (1..5).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(4, length: 2)

    assert_equal 3, shops.total_pages
    assert_equal 4, shops.current_page
    assert_equal 1, shops.first_page
    assert_equal 3, shops.previous_page
    assert_nil shops.next_page
    assert_equal 3, shops.last_page
    assert shops.out_of_bounds?
    assert_equal [], shops.map(&:id)
  end

  test 'empty padding' do
    shops = Shop.search('').page(1, length: 2, padding: 2)

    assert_equal 1, shops.total_pages
    assert_equal 1, shops.current_page
    assert_equal 1, shops.first_page
    assert_nil shops.previous_page
    assert_nil shops.next_page
    assert_equal 1, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [], shops.map(&:id)
  end

  test 'first padding' do
    (1..7).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(1, length: 2, padding: 2)

    assert_equal 3, shops.total_pages
    assert_equal 1, shops.current_page
    assert_equal 1, shops.first_page
    assert_nil shops.previous_page
    assert_equal 2, shops.next_page
    assert_equal 3, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [5, 4], shops.map(&:id)
  end

  test 'middle padding' do
    (1..7).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(2, length: 2, padding: 2)

    assert_equal 3, shops.total_pages
    assert_equal 2, shops.current_page
    assert_equal 1, shops.first_page
    assert_equal 1, shops.previous_page
    assert_equal 3, shops.next_page
    assert_equal 3, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [3, 2], shops.map(&:id)
  end

  test 'last padding' do
    (1..7).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(3, length: 2, padding: 2)

    assert_equal 3, shops.total_pages
    assert_equal 3, shops.current_page
    assert_equal 1, shops.first_page
    assert_equal 2, shops.previous_page
    assert_nil shops.next_page
    assert_equal 3, shops.last_page
    assert_not shops.out_of_bounds?
    assert_equal [1], shops.map(&:id)
  end

  test 'out padding' do
    (1..7).step do |id|
      shop = Shop.create(id: id)
    end
    wait
    shops = Shop.search('').page(4, length: 2, padding: 2)

    assert_equal 3, shops.total_pages
    assert_equal 4, shops.current_page
    assert_equal 1, shops.first_page
    assert_equal 3, shops.previous_page
    assert_nil shops.next_page
    assert_equal 3, shops.last_page
    assert shops.out_of_bounds?
    assert_equal [], shops.map(&:id)
  end

end
