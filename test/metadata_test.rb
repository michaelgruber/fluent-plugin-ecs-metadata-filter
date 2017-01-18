require 'test_helper'

class MetadataTest < Minitest::Test
  include TestSupport::Data

  def setup
    @metadata = FluentECS::Metadata.new(metadata_attributes)
  end

  def test_accessors
    assert_equal 'westeros', @metadata.cluster
  end

  def test_creating_tasks
    tasks = @metadata.tasks
    assert tasks.all? { |t| t.is_a?(FluentECS::Task) }
    assert tasks.all? { |t| t.container_instance == @metadata }
  end

  def test_retrieving_containers
    containers = @metadata.containers
    assert containers.all? { |c| c.is_a?(FluentECS::Container) }
    assert containers.all? { |c| c.container_instance == @metadata }
  end
end
