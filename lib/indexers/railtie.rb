module Indexers
  class Railtie < Rails::Railtie

    config.before_initialize do
      Dir["#{Rails.root}/app/indexers/**/*_indexer.rb"].each do |file|
        load file
      end
    end

    initializer 'indexers.active_record' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.include(
          Indexers::Extensions::ActiveRecord::Base
        )
      end
    end

    rake_tasks do
      load 'tasks/indexers.rake'
    end

  end
end
