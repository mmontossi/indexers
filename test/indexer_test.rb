require 'test_helper'

class IndexerTest < ActiveSupport::TestCase

  test 'name' do
    assert_equal 'shop', Shop.indexer.name
  end

  test '<=>' do
    assert_equal(
      %w(product shop),
      [Shop.indexer, Product.indexer].sort.map(&:name)
    )
  end

  test 'has parent' do
    assert Product.indexer.has_parent?
    assert_not Shop.indexer.has_parent?
  end

  test 'search' do
    assert_kind_of Indexers::Collection, Shop.search('')
    assert_kind_of ActiveRecord::Relation, Shop.search
  end

end
