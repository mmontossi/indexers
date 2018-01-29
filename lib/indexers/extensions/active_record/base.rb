module Indexers
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def inherited(subclass)
            filename = subclass.name.try(:underscore)
            if filename && File.exist?("#{Rails.root}/app/indexers/#{filename}_indexer.rb")
              subclass.include Indexers::Concern
            end
            super
          end

        end
      end
    end
  end
end
