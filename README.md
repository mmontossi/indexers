[![Gem Version](https://badge.fury.io/rb/indices.svg)](http://badge.fury.io/rb/indices)
[![Code Climate](https://codeclimate.com/github/mmontossi/indices/badges/gpa.svg)](https://codeclimate.com/github/mmontossi/indices)
[![Build Status](https://travis-ci.org/mmontossi/indices.svg)](https://travis-ci.org/mmontossi/indices)
[![Dependency Status](https://gemnasium.com/mmontossi/indices.svg)](https://gemnasium.com/mmontossi/indices)

# Indices

Model search indices with elasticsearch in rails.

## Why

I did this gem to:

- Gain control of the queries without losing simplicity.
- Have out of the box integration with activerecord and pagers.
- Deal with the just in time nature of elasticsearch.
- Integrate activerecord tool on it.
- Have a convention of how to integrate suggestions.

## Install

Put this line in your Gemfile:
```ruby
gem 'indices'
```

Then bundle:
```
$ bundle
```

To install Redis you can use homebrew:
```
brew install elasticsearch24
```

NOTE: This gem is tested agains version 2.4.

## Configuration

Generate the configuration file:
```
bundle exec rails g indices:install
```

Configure the global settings:
```ruby
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
    price type: 'long'
    currency type: 'string'
    product_suggestions do
      type 'completion'
      analyzer 'simple'
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
    completion do
      field "#{type}_suggestions"
    end
  end

  config.add_computed_sort :price do |direction|
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

Generate an index:
```
bundle exec rails g indices:index products
```

Configure the index:
```ruby
Indices.define :products do

  mappings do
    properties :name, :category, :price, :product_suggestions
  end

  serializer do |record|
    set record, :name, :category, :price
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

## Usage

### Indexing

Ocurrs everytime you create or destroy a record:
```ruby
product = Product.create(name: 'Les Paul', category: 'Gibson')
```

You can force it manually by:
```ruby
product.index
product.reindex
product.unindex
```

At any time you can force a full rebuild:
```
bundle exec rake indices:rebuild
```

Or if you need it, just a build:
```
bundle exec rake indices:build
```

### Search

The search parameters are sent to previous configured block:
```ruby
@products = Product.search(name: 'Test')
```

You can use the returned value as a collection in views:
```erb
<%= render @products %>
```

### Includes

Same as using activerecord relations:
```ruby
Product.search(includes: :shop)
```

### With / Without

You can force a record to be part of the results by id:
```ruby
Product.search(with: 4)
```

Or the opposite:
```ruby
Product.search(without: 4)
```

### Pagination

Works the same as [Pagers gem](https://github.com/mmontossi/pagers):
```ruby
@products.page 1, padding: 4, length: 30
```

And you can send the collection directly to the helper in views:
```erb
<%= paginate @products %>
```

### Order

Works the same as in relations:
```ruby
@products.order(name: :asc)
```

To use a computed_sort:
```ruby
@products.order(price: :asc)
```

NOTE: To sort by a string column, you must declare the mapping raw.

### Suggestions

The suggestion parameters are sent to previous configured block:
```ruby
Indices.suggest :products, 'gibson'
```

Returns array of hashes with a text property:
```ruby
[{ text: 'Les Paul' }, ...]
```

## Credits

This gem is maintained and funded by [mmontossi](https://github.com/mmontossi).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
