namespace :indexes do
  desc 'Build all indexes.'
  task build: :environment do
    Indexes.build
  end

  desc 'Rebuild all indexes.'
  task rebuild: :environment do
    Indexes.rebuild
  end
end
