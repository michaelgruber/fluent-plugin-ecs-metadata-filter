module FluentECS
  class Metadata
    include Resource

    self.resource_endpoint = '/metadata'

    attr_accessor :arn,   :cluster, :version
    attr_writer   :tasks, :containers

    def initialize(attrs = {})
      @arn       = attrs['ContainerInstanceArn']
      @cluster   = attrs['Cluster']
      @version   = attrs['Version']
      @task_data = attrs['Tasks'] || Array(Task.get['Tasks'])
    end

    def tasks
      @tasks ||= @task_data.map do |d|
        Task.new(d).tap { |t| t.container_instance = self }
      end
    end

    def containers
      @containers ||= tasks.map(&:containers).flatten
    end

    class << self
      def take
        Metadata.new(get)
      end
    end
  end
end
