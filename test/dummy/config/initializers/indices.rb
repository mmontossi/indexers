Indices.configure do |config|

  config.hosts = %w(localhost:9200)
  config.log = false
  config.trace = false

  config.mappings do
    name do
      type 'string'
      fields do
        raw do
          type 'string'
          index 'not_analyzed'
        end
      end
    end
    category type: 'string'
    shop_id type: 'long'
    price type: 'long'
    currency type: 'string'
    product_suggestions do
      type 'completion'
      analyzer 'simple'
      context do
        shop_id do
          type 'category'
          default 'all'
        end
      end
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
      context do
        if shop
          shop_id (shop.id.to_s || 'all')
        end
      end
    end
  end

  config.computed_sort :price do |direction|
    _script do
      type 'number'
      script do
        inline "if (_source.currency == 'UYU') { doc['price'].value * 30 }"
      end
      order direction
    end
  end

end
