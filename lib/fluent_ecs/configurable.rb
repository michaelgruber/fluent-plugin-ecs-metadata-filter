module FluentECS
  module Configurable
    class Config
      attr_accessor :cache_size, :cache_ttl, :fields
    end

    def config
      @config ||= Config.new
    end

    def configure(&_block)
      yield config
    end
  end

  extend Configurable
end
