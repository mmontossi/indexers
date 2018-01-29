[![Gem Version](https://badge.fury.io/rb/indexers.svg)](http://badge.fury.io/rb/indexers)
[![Code Climate](https://codeclimate.com/github/museways/indexers/badges/gpa.svg)](https://codeclimate.com/github/museways/indexers)
[![Build Status](https://travis-ci.org/museways/indexers.svg)](https://travis-ci.org/museways/indexers)
[![Dependency Status](https://gemnasium.com/museways/indexers.svg)](https://gemnasium.com/museways/indexers)

# Indexers

Dsl to delegate searches to elasticsearch in rails.

## Why

We did this gem to:

- Gain control of the queries without losing simplicity.
- Have out of the box integration with activerecord and pagers.
- Deal with the just in time nature of elasticsearch.
- Integrate activerecord includes on it.
- Have a convention of how to use suggestions.

## Install

Put this line in your Gemfile:
```ruby
gem 'indexers'
```

Then bundle:
```
$ bundle
```

To install Redis you can use homebrew:
```
$ brew install elasticsearch
```

NOTE: This gem is tested agains version 5.6.

## Configuration

Generate the configuration file:
```
$ bundle exec rails g indexers:install
```

Set the global settings:
```ruby
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
          min_gram: 2,
          max_gram: 20
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
    { type: 'number', script: { inline: inline }, order: direction }
  end

end
```

NOTE: You may want to personalize the generated config/elasticsearch.yml.

### Definitions

Generate an index:
```
$ bundle exec rails g indexers:indexer product
```

Define the mappings, serialization and search in the index:
```ruby
class ProductIndexer < ApplicationIndexer

  def mappings
    properties = configuration.properties.slice(
      :name, :category, :shop_id, :price, :currency, :product_suggestion
    )
    { properties: properties, _parent: { type: 'shop' } }
  end

  def serialize(record)
    record.slice(
      :name, :category, :shop_id, :price, :position, :currency
    ).merge(
      product_suggestion: {
        input: record.name,
        contexts: {
          shop_id: [record.shop_id.to_s, 'all'].compact
        }
      }
    )
  end

  def query(term, options={})
    must = {}
    if term.present?
      must[:multi_match] = {
        query: term,
        type: 'phrase_prefix',
        fields: %w(name category)
      }
    else
      must[:match_all] = {}
    end
    filter = {}
    if shop = options[:shop]
      filter[:term] = {
        _parent: shop.id
      }
    end
    { query: {
      bool: {
        must: must,
        filter: filter
      }
    } }
  end

end
```

### Indexing

The index will be updated every time a record is created, updated or destroyed:
```ruby
product = Product.create(name: 'Les Paul', category: 'Gibson')
```

You can force this actions manually with:
```ruby
product.index
product.reindex
product.unindex
```

### Rake tasks

At any time you can build/rebuild your indexers using:
```
$ bundle exec rake indexers:index
$ bundle exec rake indexers:reindex
$ bundle exec rake indexers:unindex
```

### Search

Use the included search method in the model:
```ruby
products = Product.search('Les Paul')
```

The result can be used as a collection in views:
```erb
<%= render products %>
```

### Includes

Similar to using activerecod:
```ruby
Product.search.includes(:shop)
```

### Pagination

Works the same as [pagers gem](https://github.com/museways/pagers):
```ruby
Products.search.page(1, padding: 4, length: 30)
```

And you can send the collection directly to the view helper:
```erb
<%= paginate products %>
```

### Order

Same as using activerecord:
```ruby
Product.search.order(name: :asc)
```

NOTE: You can use a computed sort declared it in the configuration.

### Suggestions

You can get suggestions using the previous configured block:
```ruby
Indexers.suggest :product, 'gibson'
```

The result is an array of hashes with a text property and the record:
```ruby
[{ text: 'Les Paul', <ActiveRecord::Base ...> }, ...]
```

## Contributing

Any issue, pull request, comment of any kind is more than welcome!

We will mainly ensure compatibility to Rails, AWS, PostgreSQL, Redis, Elasticsearch and FreeBSD. 

## Credits

This gem is maintained and funded by [museways](https://github.com/museways).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
