module Indices
  module Concern
    extend ActiveSupport::Concern

    included do
      after_commit :index, on: :create
      after_commit :reindex, on: :update
      after_commit :unindex, on: :destroy
    end

    %i(index reindex unindex).each do |name|
      define_method name do
        self.class.index.send name, self
      end
    end

    module ClassMethods

      delegate :search, to: :index

    end
  end
end
