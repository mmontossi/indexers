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
