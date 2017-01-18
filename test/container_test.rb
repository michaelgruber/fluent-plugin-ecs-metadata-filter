require 'test_helper'

class ContainerTest < Minitest::Test
  include TestSupport::Hooks
  include TestSupport::Data

  def docker_id
    '814007b2fdcfd6817edc6da30e602dbc103ec87cfc337187122ce198e15af656'
  end

  def setup
    configure_defaults
  end

  def found_container
    VCR.use_cassette(:introspection) do
      FluentECS::Container.find(docker_id)
    end
  end

  def test_accessors
    container = FluentECS::Container.new(container_attributes)
    assert_equal 'jaime', container.name
  end

  def test_to_h
    FluentECS.configure { |c| c.fields = %w(cluster family name) }
    expected = {
      'cluster' => 'westeros',
      'family'  => 'stark',
      'name'    => 'eddard'
    }
    assert_equal expected, found_container.to_h
  end

  def test_to_h_with_different_fields
    FluentECS.configure { |c| c.fields = %w(known_status cluster family name) }
    expected = {
      'known_status' => 'STOPPED',
      'cluster'      => 'westeros',
      'family'       => 'stark',
      'name'         => 'eddard'
    }
    assert_equal expected, found_container.to_h
  end

  def test_respond_to?
    assert FluentECS::Container.new.respond_to?(:to_h)
  end

  def test_method_missing_still_works
    assert_raises NoMethodError do
      FluentECS::Container.new.send(:notarealmethod)
    end
  end

  def test_find_container
    VCR.use_cassette('introspection') do
      id = 'c6d3e1f60b8e3752c9c15513b78d8b48b67dc4b4c888815f9ffcba80739fb51f'
      found = FluentECS::Container.find(id)
      assert_equal 'jon-snow', found.name
    end
  end

  def test_container_not_found
    VCR.use_cassette('introspection') do
      not_found = FluentECS::Container.find('n0tth3r3')
      assert_nil not_found
    end
  end

  def test_requests_again_if_not_in_cache
    VCR.use_cassette('introspection', allow_playback_repeats: false) do
      # populates cache
      cache = '86ad8148595a8235d90afcd7b3801520d8ff74551f812752f6f758d2357ab133'
      FluentECS::Container.find(cache)

      # doesnt make another request
      hit = 'c6d3e1f60b8e3752c9c15513b78d8b48b67dc4b4c888815f9ffcba80739fb51f'
      FluentECS::Container.find(hit)

      # not in cache so another request is made
      assert_raises VCR::Errors::UnhandledHTTPRequestError do
        miss = 'n0t1nc4ch3'
        assert_nil FluentECS::Container.find(miss)
      end
    end
  end

  def test_caches_not_found
    VCR.use_cassette('introspection', allow_playback_repeats: false) do
      assert_nil FluentECS::Container.find('willb3c4ch3d')

      assert_raises VCR::Errors::UnhandledHTTPRequestError do
        FluentECS::Container.find('n0t1nc4ch3')
      end

      assert_nil FluentECS::Container.find('willb3c4ch3d')
    end
  end
end
