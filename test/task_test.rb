require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  teardown do
    Indexes.destroy
  end

  test 'build' do
    assert_nothing_raised do
      Rake::Task['indexes:build'].invoke
    end
  end

  test 'rebuild' do
    assert_nothing_raised do
      Rake::Task['indexes:rebuild'].invoke
    end
  end

end
