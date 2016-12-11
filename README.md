[![Gem Version](https://badge.fury.io/rb/indexers.svg)](http://badge.fury.io/rb/indexers)
[![Code Climate](https://codeclimate.com/github/mmontossi/indexers/badges/gpa.svg)](https://codeclimate.com/github/mmontossi/indexers)
[![Build Status](https://travis-ci.org/mmontossi/indexers.svg)](https://travis-ci.org/mmontossi/indexers)
[![Dependency Status](https://gemnasium.com/mmontossi/indexers.svg)](https://gemnasium.com/mmontossi/indexers)

# Indexers

Model search indexers with elasticsearch in rails.

## Why

I did this gem to:

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
$ brew install elasticsearch24
```

NOTE: This gem is tested agains version 2.4.

## Configuration

Generate the configuration file:
```
$ bundle exec rails g indexers:install
```

Set the global settings:
```ruby
Indexers.configure do |config|

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
    price type: 'long'
    currency type: 'string'
    product_suggestions do
      type 'completion'
      analyzer 'simple'
    end
  end

end
```

### Definitions

Generate an index:
```
$ bundle exec rails g indexer products
```

Define the mappings, serialization and search in the index:
```ruby
Indexers.define :products do

  mappings do
    properties :name, :category, :price, :product_suggestions
  end

  serialization do |record|
    extract record, :name, :category, :price
    product_suggestions do
      input [record.name, transliterate(record.name)].uniq
      output record.name
    end
  end

  search do |*args|
    options = args.extract_options!
    term = args.first
    query do
      if term.present?
        multi_match do
          query term
          type 'phrase_prefix'
          fields %w(name category)
        end
      else
        match_all
      end
    end
  end

end
```

If you need to personalize the analysis, you have to add it to the configuration:

```ruby
Indexers.configure do |config|

  config.analysis do
    filter do
      ngram do
        type 'nGram'
        min_gram 2
        max_gram 20
      end
    end
    analyzer do
      ngram do
        type 'custom'
        tokenizer 'standard'
        filter %w(lowercase ngram)
      end
    end
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
$ bundle exec rake indexers:build
$ bundle exec rake indexers:rebuild
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

### With / Without

You can force a record to be part of the results by id:
```ruby
Products.search.with(4)
```

Or the opposite:
```ruby
Products.search.without(4)
```

### Pagination

Works the same as [pagers gem](https://github.com/mmontossi/pagers):
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

You can use a computed sort by declare it in the configuration:
```ruby
Indexers.configure do |config|

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
```

### Suggestions

You need to first define the logic in the configuration:
```ruby
Indexers.configure do |config|

  config.suggestions do |name, term, options={}|
    type = name.to_s.singularize
    text (term || '')
    completion do
      field "#{type}_suggestions"
    end
  end

end
```

Then you can get suggestions using the suggest method:
```ruby
Indexers.suggest :products, 'gibson'
```

The result is an array of hashes with a text property:
```ruby
[{ text: 'Les Paul' }, ...]
```

## Credits

This gem is maintained and funded by [mmontossi](https://github.com/mmontossi).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
