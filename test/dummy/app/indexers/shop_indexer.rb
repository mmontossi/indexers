class ShopIndexer < ApplicationIndexer

  def mappings
    { properties: configuration.properties.slice(:name) }
  end

  def serialize(record)
    record.slice :name
  end

  def query(term, options={})
    query = {}
    if term.present?
      query[:match] = {
        name: {
          query: term,
          type: 'phrase_prefix'
        }
      }
    else
      query[:match_all] = {}
    end
    { query: query }
  end

end
