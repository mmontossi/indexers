module Indexers
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def inherited(subclass)
            super
            if subclass.name
              id = subclass.name.parameterize('_').to_sym
              if indexer = Indexers.definitions.find(id)
                subclass.include Indexers::Concern
                subclass.define_singleton_method :indexer do
                  indexer
                end
              end
            end
          end

        end
      end
    end
  end
end
