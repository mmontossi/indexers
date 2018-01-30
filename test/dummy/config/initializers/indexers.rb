Indexers.configure do |config|

  config.properties = {
    category: { type: 'string' },
    shop_id: { type: 'long' },
    price: { type: 'long' },
    position: { type: 'long' },
    currency: { type: 'string' },
    name: {
      type: 'string',
      fields: {
        raw: {
          type: 'string',
          index: 'not_analyzed'
        }
      }
    },
    product_suggestion: {
      type: 'completion',
      analyzer: 'simple',
      contexts: {
        name: 'shop_id',
        type: 'category'
      }
    }
  }

  config.settings = {
    analysis: {
      filter: {
        ngram: {
          type: 'nGram',
          min_gram: '2',
          max_gram: '20'
        }
      }
    }
  }

  config.suggestion :product do |term, options={}|
    prefix = (term || '')
    contexts = {}
    if shop = options[:shop]
      contexts[:shop_id] = (shop.id.to_s || 'all')
    end
    { prefix: prefix, completion: { field: 'product_suggestion', contexts: contexts } }
  end

  config.computed_sort :price do |direction|
    inline = <<~CODE
      if (params['_source']['currency'] == 'UYU') {
        doc['price'].value * 30
      }
    CODE
    { type: 'number', script: { source: inline }, order: direction }
  end

end
