require 'test_helper'

class DslTest < ActiveSupport::TestCase

  test 'search' do
    shop = Shop.create
    seed = rand
    days = [1,2,3]
    opens_at = Time.now.to_i
    closes_at = (Time.now + 1.day).to_i
    assert_equal(
      {
        query: {
          function_score: {
            functions: [
              { random_score: { seed: seed } },
              {
                weight: 400,
                filter: {
                  bool: {
                    must: [
                      { term: {} }
                    ]
                  }
                }
              }
            ]
          },
          query: {
            filtered: {
              filter: {
                bool: {
                  should: [
                    { term: { :'schedules.days' => days } }
                  ],
                  must: [
                    { range: { :'schedules.opens_at' => { lte: opens_at } } }
                  ],
                  must_not: [
                    {
                      has_parent: {
                        type: 'products',
                        query: {
                          filtered: {
                            filter: {
                              bool: {
                                must: [
                                  {
                                    term: {
                                      _parent: shop.id
                                    }
                                  }
                                ]
                              }
                            },
                            query: {
                              match_all: {}
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        },
        sort: [
          { name: 'asc' }
        ],
        size: {}
      },
      build do
        query do
          function_score do
            functions do
              random_score do
                seed seed
              end
              filter weight: 400 do
                bool do
                  must do
                    term
                  end
                end
              end
            end
          end
          query do
            filtered do
              filter do
                bool do
                  should do
                    term 'schedules.days' => days
                  end
                  must do
                    range 'schedules.opens_at' do
                      lte opens_at
                    end
                  end
                  must_not do
                    has_parent do
                      type 'products'
                      query :product, shop: shop
                    end
                  end
                end
              end
            end
          end
        end
        sort %w(asc) do |order|
          name order
        end
        size
      end
    )
  end

  private

  def build(&block)
    Indexers::Dsl::Searches.new(&block).to_h
  end

end
