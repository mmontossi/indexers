module Indexers
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def inherited(subclass)
            super
            if File.exist?("#{Rails.root}/app/indexers/#{subclass.name.underscore}_indexer.rb")
              subclass.include Indexers::Concern
            end
          end

        end
      end
    end
  end
end
