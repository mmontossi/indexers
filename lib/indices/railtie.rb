module Indices
  class Railtie < Rails::Railtie

    initializer :indices do
      Dir[Rails.root.join('app/indices/*')].each do |index|
        load index
      end
    end

    rake_tasks do
      load 'tasks/indices.rake'
    end

  end
end
