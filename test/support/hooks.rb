module TestSupport
  module Hooks
    def configure_defaults
      FluentECS.configure do |c|
        c.cache_ttl  = :none
        c.cache_size = 1000
        c.fields     = ['docker_name']
      end
    end

    def remove_cache
      needed = FluentECS::Container.instance_variable_defined?(:@cache)
      FluentECS::Container.remove_instance_variable(:@cache) if needed
    end

    def remove_config
      needed = FluentECS.instance_variable_defined?(:@config)
      FluentECS.remove_instance_variable(:@config) if needed
    end

    def remove_to_h
      needed = FluentECS::Container.method_defined?(:to_h)
      FluentECS::Container.send(:remove_method, :to_h) if needed
    end

    def teardown
      remove_cache
      remove_config
      remove_to_h
    end
  end
end
