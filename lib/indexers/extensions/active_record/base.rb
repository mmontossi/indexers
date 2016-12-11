module Indexers
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def inherited(subclass)
            super
            name = subclass.name.parameterize('_').to_sym
            if indexer = Indexers.definitions.find(name)
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
