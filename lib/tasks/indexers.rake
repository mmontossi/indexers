namespace :indexers do
  desc 'Index all records.'
  task index: :environment do
    Indexers.index
  end

  desc 'Reindex all records.'
  task reindex: :environment do
    Indexers.reindex
  end

  desc 'Unindex all records.'
  task unindex: :environment do
    Indexers.unindex
  end
end
