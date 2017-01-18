require 'securerandom'

module TestSupport
  module Data
    def metadata_attributes
      metadata_response.merge(tasks_response)
    end

    def metadata_response
      {
        'Cluster'              => cluster,
        'ContainerInstanceArn' => container_instance_arn,
        'Version'              => ecs_agent_version
      }
    end

    def tasks_response
      { 'Tasks' => [task_data] }
    end

    def task_data
      {
        'Arn'           => task_arn,
        'DesiredStatus' => task_status,
        'KnownStatus'   => task_status,
        'Family'        => task_family,
        'Version'       => task_version,
        'Containers'    => [container_data]
      }
    end
    alias task_attributes task_data

    def container_data
      {
        'DockerId'   => docker_id,
        'DockerName' => docker_name,
        'Name'       => container_name
      }
    end
    alias container_attributes container_data

    def account_id
      rand(10**12)
    end

    def cluster
      'westeros'
    end

    def container_instance_arn
      "arn:aws:ecs:#{region}:#{account_id}:" \
      "container-instance/#{container_instance_uuid}"
    end

    def container_name
      'jaime'
    end

    def docker_id
      SecureRandom.hex(32)
    end

    def docker_name
      "ecs-#{task_family}-#{task_version}-#{docker_name_id}"
    end

    def docker_name_id
      SecureRandom.hex(10)
    end

    def ecs_agent_version
      'Amazon ECS Agent - v1.13.1 (efe53c6)'
    end

    def region
      'us-east-1'
    end

    def task_arn
      "arn:aws:ecs:#{region}:#{account_id}:task/#{task_uuid}"
    end

    def task_family
      'lannister'
    end

    def task_status
      'RUNNING'
    end

    def task_uuid
      SecureRandom.uuid
    end
    alias container_instance_uuid task_uuid

    def task_version
      '4'
    end
  end
end
