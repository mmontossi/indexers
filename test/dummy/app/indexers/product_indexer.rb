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
    bool = {}
    query = { bool: bool }
    if term.present?
      bool[:must] = {
        multi_match: {
          query: term,
          type: 'phrase_prefix',
          fields: %w(name category)
        }
      }
    else
      bool[:must] = { match_all: {} }
    end
    if shop = options[:shop]
      bool[:filters] = {
        term: { _parent: shop.id }
      }
    end
    query
  end

end
