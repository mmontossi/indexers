module Indexes
  class Railtie < Rails::Railtie

    initializer :indexes do
      Dir[Rails.root.join('app/indexes/*')].each do |index|
        load index
      end
    end

    rake_tasks do
      load 'tasks/indexes.rake'
    end

  end
end
