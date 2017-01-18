require 'test_helper'

class TaskTest < Minitest::Test
  include TestSupport::Data

  def setup
    @task = FluentECS::Task.new(task_attributes)
  end

  def test_accessors
    assert_equal 'lannister', @task.family
  end

  def test_retrieving_containers
    containers = @task.containers
    assert containers.all? { |c| c.is_a?(FluentECS::Container) }
    assert containers.all? { |c| c.task == @task }
  end
end
