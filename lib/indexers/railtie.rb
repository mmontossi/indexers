module Indexers
  class Railtie < Rails::Railtie

    initializer 'indexers.active_record' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.include(
          Indexers::Extensions::ActiveRecord::Base
        )
      end
    end

    config.after_initialize do
      Dir[Rails.root.join('app/indexers/**/*_indexer.rb')].each do |file|
        load file
      end
    end

    rake_tasks do
      load 'tasks/indexers.rake'
    end

  end
end
