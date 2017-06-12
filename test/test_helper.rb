require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fluent_ecs'

require 'minitest/autorun'
require 'fluent/test'
require 'fluent/test/driver/filter'

require 'webmock/minitest'
require 'vcr'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
end
