[![Gem Version](https://badge.fury.io/rb/indexes.svg)](http://badge.fury.io/rb/indexes)
[![Code Climate](https://codeclimate.com/github/mmontossi/indexes/badges/gpa.svg)](https://codeclimate.com/github/mmontossi/indexes)
[![Build Status](https://travis-ci.org/mmontossi/indexes.svg)](https://travis-ci.org/mmontossi/indexes)
[![Dependency Status](https://gemnasium.com/mmontossi/indexes.svg)](https://gemnasium.com/mmontossi/indexes)

# Indexes

Model search indexes with elasticsearch in rails.

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
gem 'indexes'
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

## Usage

### Configuration

Generate the configuration file:
```
$ bundle exec rails g indexes:install
```

Configure the connection, analysis, mappings and computed sorts:
```ruby
Indexes.configure do |config|

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

### Analysis

You can customize the analysis setting in the configuration:
```ruby
Indexes.configure do |config|

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

Generate an index:
```
$ bundle exec rails g index products
```

Define the mappings, serializatio and search in the index:
```ruby
Indexes.define :products do

  mappings do
    properties :name, :category, :price
  end

  serialization do |record|
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

NOTE: Properties are referenced from the configuration file.

Then everytime you create, update or destroy a record the index will be updated:
```ruby
product = Product.create(name: 'Les Paul', category: 'Gibson')
```

You can force it individually by using this methods:
```ruby
product.index
product.reindex
product.unindex
```

Or invoke the rake tasks to process all records:
```
$ bundle exec rake indexes:build
$ bundle exec rake indexes:rebuild
```

### Search

Then you can use the search method:
```ruby
products = Product.search(name: 'Test')
```

The result can be used as a collection in views:
```erb
<%= render products %>
```

### Includes

Same as using activerecord relations:
```ruby
Product.includes(:shop)
```

### With / Without

You can force a record to be part of the results by id:
```ruby
Product.search.with(4)
```

Or the opposite:
```ruby
Product.search.without(4)
```

### Pagination

Works the same as [pagers gem](https://github.com/mmontossi/pagers):
```ruby
Product.search.page(1, padding: 4, length: 30)
```

And you can send the collection directly to the view helper:
```erb
<%= paginate products %>
```

### Order

Same as using activerecord order:
```ruby
products.order(name: :asc)
```

You can use computed sort by declare them in the configuration:
```ruby
Indexes.configure do |config|

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

### Suggestions

You need to first define the logic in the configuration:
```ruby
Indexes.configure do |config|

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
Indexes.suggest :products, 'gibson'
```

The result is an array of hashes with a text property:
```ruby
[{ text: 'Les Paul' }, ...]
```

## Credits

This gem is maintained and funded by [mmontossi](https://github.com/mmontossi).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
