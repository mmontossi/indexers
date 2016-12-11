require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  teardown do
    Indexers.unindex
  end

  test 'index' do
    assert_nothing_raised do
      Rake::Task['indexers:index'].invoke
    end
  end

  test 'reindex' do
    assert_nothing_raised do
      Rake::Task['indexers:reindex'].invoke
    end
  end

  test 'unindex' do
    assert_nothing_raised do
      Rake::Task['indexers:unindex'].invoke
    end
  end

end
