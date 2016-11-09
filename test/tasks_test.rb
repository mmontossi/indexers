require 'test_helper'

class TasksTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  teardown do
    Indices.destroy
  end

  test 'build' do
    assert_nothing_raised do
      Rake::Task['indices:build'].invoke
    end
  end

  test 'rebuild' do
    assert_nothing_raised do
      Rake::Task['indices:rebuild'].invoke
    end
  end

end
