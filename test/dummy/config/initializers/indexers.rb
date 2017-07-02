Indexers.configure do |config|

  config.hosts = %w(localhost:9200)
  config.log = false
  config.trace = false

  config.mappings do
    category type: 'text'
    shop_id type: 'long'
    price type: 'long'
    currency type: 'text'
    name do
      type 'text'
      fields do
        raw do
          type 'keyword'
        end
      end
    end
    product_suggestions do
      type 'completion'
      analyzer 'simple'
      contexts [
        { name: 'shop_id', type: 'category' }
      ]
    end
  end

  config.analysis do
    filter do
      ngram do
        type 'nGram'
        min_gram 2
        max_gram 20
      end
    end
  end

  config.suggestions do |name, term, options={}|
    type = name.to_s.singularize
    text (term || '')
    shop = options[:shop]
    completion do
      field "#{type}_suggestions"
      contexts do
        if shop
          shop_id (shop.id.to_s || 'all')
        end
      end
    end
  end

  config.computed_sort :price do |direction|
    type 'number'
    script do
      inline "if (params['_source']['currency'] == 'UYU') { doc['price'].value * 30 }"
    end
    order direction
  end

end
