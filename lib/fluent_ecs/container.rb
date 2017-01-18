module FluentECS
  class Container
    extend Forwardable
    attr_accessor :docker_id, :docker_name, :name, :task

    def_delegators :@task,  :container_instance, :desired_status,
                   :family, :known_status,       :version

    def_delegators :container_instance, :cluster

    def_delegator  :@container_instance, :arn,     :container_instance_arn
    def_delegator  :@container_instance, :version, :container_instance_version
    def_delegator  :@task,               :arn,     :task_arn

    def initialize(attrs = {})
      @docker_id   = attrs['DockerId']
      @docker_name = attrs['DockerName']
      @name        = attrs['Name']
    end

    def method_missing(method_id, *args, &_block)
      if method_id == :to_h
        self.class.class_eval hash_definition
        to_h
      else
        super
      end
    end

    def respond_to_missing?(method_id, include_private = false)
      method_id == :to_h || super
    end

    def hash_definition
      fields = FluentECS.config.fields
      %(
        def to_h
          { #{fields.map { |f| "'#{f}' => #{f}" }.join(',')} }
        end
      )
    end
    private :hash_definition

    class << self
      def cache
        @cache ||= LruRedux::TTL::ThreadSafeCache.new(
          FluentECS.config.cache_size,
          FluentECS.config.cache_ttl
        )
      end

      def find(docker_id)
        cache.getset(docker_id) do
          Metadata.take.containers.each { |c| cache[c.docker_id] = c }
          cache[docker_id] # cache value nil if container is not in response
        end
      end
    end
  end
end
