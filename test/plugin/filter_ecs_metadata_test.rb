require 'test_helper'
require 'fluent/plugin/filter_ecs_metadata'

class ECSMetadataFilterTest < Minitest::Test
  include Fluent
  include TestSupport::Hooks

  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver(conf = '', log = nil)
    log ||= default_log
    Test::FilterTestDriver.new(ECSMetadataFilter, log).configure(conf, true)
  end

  def emit(conf = '', msg = {}, driver = nil)
    driver = create_driver(conf)
    driver.emit(msg, @time)
    [driver.run.filtered, driver]
  end

  def docker_id
    '86ad8148595a8235d90afcd7b3801520d8ff74551f812752f6f758d2357ab133'
  end

  def default_log
    "var.lib.docker.containers.#{docker_id}.#{docker_id}-json.log"
  end

  def test_fluent_defaults
    instance = create_driver.instance
    assert_equal 1000, instance.cache_size
    assert_equal 60 * 60, instance.cache_ttl
    assert_equal %w(docker_name family cluster name), instance.fields
  end

  def test_compiling_default_regexp
    instance = create_driver.instance
    tag_regexp = instance.instance_variable_get(:@tag_regexp_compiled)
    assert_equal docker_id, tag_regexp.match(default_log)['docker_id']
  end

  def test_configuring_fluent_ecs
    instance = create_driver.instance
    assert_equal FluentECS.config.cache_ttl, instance.cache_ttl
    assert_equal FluentECS.config.cache_size, instance.cache_size
    assert_equal FluentECS.config.fields, instance.fields
  end

  def test_with_metadata
    VCR.use_cassette('introspection') do
      expected = { 'ecs' => {
        'docker_name' => 'ecs-targaryen-2-daenerys-e4f1ee88ef81d28c5500',
        'family'      => 'targaryen',
        'cluster'     => 'westeros',
        'name'        => 'daenerys'
      } }

      es, = emit
      assert_equal expected, es.instance_variable_get(:@record_array)[0]
    end
  end

  def test_with_nondefault_fields
    VCR.use_cassette('introspection') do
      expected = { 'ecs' => {
        'docker_name' => 'ecs-targaryen-2-daenerys-e4f1ee88ef81d28c5500',
        'family'      => 'targaryen'
      } }

      es, = emit('fields docker_name,family')
      assert_equal expected, es.instance_variable_get(:@record_array)[0]
    end
  end

  def test_with_invalid_field
    assert_raises Fluent::ConfigError do
      emit('fields docker_name,nosuchfield')
    end
  end

  def test_introspection_failing_with_system_error
    [Errno::ECONNREFUSED, HTTParty::Error, Timeout::Error].each do |e|
      stub_request(:get, 'localhost:51678/v1/metadata').to_raise(e)
      es, driver = emit

      expected_record = {}
      assert_equal expected_record, es.instance_variable_get(:@record_array)[0]

      expected_log = 'Exception from WebMock'
      assert_match expected_log, driver.instance.log.out.logs[0]
    end
  ensure
    WebMock.reset! # in case of failed assertion, avoid more failures
  end

  def test_introspection_failing_with_http_error
    VCR.use_cassette('errors') do
      expected_log = 'GET http://localhost:51678/v1/metadata' \
                     ' failed with code: 500'
      expected_record = {}

      es, driver = emit
      assert_equal expected_record, es.instance_variable_get(:@record_array)[0]
      assert_match expected_log, driver.instance.log.out.logs[0]
    end
  end

  def test_merges_json_log_data
    VCR.use_cassette('introspection') do
      expected = { 'level' => 'INFO', 'ecs' => {
        'docker_name' => 'ecs-targaryen-2-daenerys-e4f1ee88ef81d28c5500',
        'family'      => 'targaryen'
      } }

      es, = emit('fields docker_name,family', 'log' => '{"level":"INFO"}')
      assert_equal expected, es.instance_variable_get(:@record_array)[0]
    end
  end

  def test_merging_fake_json
    VCR.use_cassette('introspection') do
      expected_log    = %q(unexpected token at '{ tricked = "you" }')
      expected_record = {
        'log' => '{ tricked = "you" }',
        'ecs' => { 'family' => 'targaryen' }
      }

      es, driver = emit('fields family', 'log' => '{ tricked = "you" }')
      assert_equal expected_record, es.instance_variable_get(:@record_array)[0]
      assert_match expected_log, driver.instance.log.out.logs[0]
    end
  end
end
