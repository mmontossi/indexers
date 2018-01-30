require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  test 'all' do
    Indexers.expects(:unindex).once
    Rake::Task['indexers:unindex'].invoke

    Indexers.expects(:index).once
    Rake::Task['indexers:index'].invoke

    Indexers.expects(:reindex).once
    Rake::Task['indexers:reindex'].invoke
  end

end
