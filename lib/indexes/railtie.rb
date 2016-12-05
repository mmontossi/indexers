module Indexes
  class Railtie < Rails::Railtie

    config.after_initialize do
      Dir[Rails.root.join('app/indexes/*')].each do |file|
        load file
      end
    end

    rake_tasks do
      load 'tasks/indexes.rake'
    end

  end
end
