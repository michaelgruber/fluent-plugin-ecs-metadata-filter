require 'test_helper'

class ResourcesTest < Minitest::Test
  def setup
    @klass = Class.new { include FluentECS::Resource }
    @klass.resource_endpoint = '/resources'
  end

  def teardown
    WebMock.reset!
  end

  def test_request_error_handling
    [Errno::ECONNREFUSED, HTTParty::Error, Timeout::Error].each do |e|
      res_stub = stub_request(:get, 'localhost:51678/v1/resources').to_raise(e)
      assert_raises FluentECS::IntrospectError do
        @klass.get
      end
      remove_request_stub(res_stub)
    end
  end

  def test_system_error_handling
    stub_request(:get, 'localhost:51678/v1/resources').to_return(status: 500)
    assert_raises FluentECS::RequestError do
      @klass.get
    end
  end
end
