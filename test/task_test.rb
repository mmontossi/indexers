require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  test 'all' do
    assert_nothing_raised do
      Rake::Task['indexers:unindex'].invoke
      Rake::Task['indexers:index'].invoke
      Rake::Task['indexers:reindex'].invoke
    end
  end

end
