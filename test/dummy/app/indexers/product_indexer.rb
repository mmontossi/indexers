Indexers.define :product do

  mappings do
    properties :name, :category, :shop_id, :price, :currency, :product_suggestions
    _parent type: 'shop'
  end

  serialize do |record|
    extract record, :name, :category, :shop_id, :price, :currency
    product_suggestions do
      input [record.name, transliterate(record.name)].uniq
      contexts do
        shop_id [record.shop_id.to_s, 'all'].compact
      end
    end
  end

  search do |*args|
    options = args.extract_options!
    shop = options[:shop]
    term = args.first
    query do
      bool do
        must do
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
        traits :filter
      end
    end
  end

  trait :filter do
    filter do
      if shop
        term do
          _parent shop.id
        end
      end
    end
  end

end
