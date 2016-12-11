module Indexers
  module Concern
    extend ActiveSupport::Concern

    included do
      after_commit :index, on: :create
      after_commit :reindex, on: :update
      after_commit :unindex, on: :destroy
    end

    %i(index reindex unindex).each do |name|
      define_method name do
        self.class.indexer.send name, self
      end
    end

    module ClassMethods

      def search(*args)
        options = args.extract_options!
        Collection.new indexer, args, options
      end

    end
  end
end
