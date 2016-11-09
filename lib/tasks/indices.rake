namespace :indices do
  desc 'Build all indices.'
  task build: :environment do
    Indices.build
  end

  desc 'Rebuild all indices.'
  task rebuild: :environment do
    Indices.rebuild
  end
end
