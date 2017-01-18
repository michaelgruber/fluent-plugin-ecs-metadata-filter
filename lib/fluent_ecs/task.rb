module FluentECS
  class Task
    include Resource
    self.resource_endpoint = '/tasks'

    attr_accessor :arn,    :container_instance, :desired_status,
                  :family, :known_status,       :version

    def initialize(attrs = {})
      @arn            = attrs['Arn']
      @desired_status = attrs['DesiredStatus']
      @family         = attrs['Family']
      @known_status   = attrs['KnownStatus']
      @version        = attrs['Version']
      @container_data = attrs['Containers']
    end

    def containers
      @containers ||= @container_data.map do |d|
        Container.new(d).tap { |c| c.task = self }
      end
    end
  end
end
