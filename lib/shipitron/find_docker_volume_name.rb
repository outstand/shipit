require 'excon'
require 'json'

module Shipitron
  class FindDockerVolumeName
    include Metaractor

    required :container_name
    required :volume_search

    def call
      volumes = container_volumes(container_name: container_name)

      volume_metadata = volumes.find do |volume|
        volume['DockerName'] =~ volume_search
      end

      if volume_metadata.nil?
        raise 'Unable to find shipitron-home volume!'
      end

      context.volume_name = volume_metadata['DockerName']
    end

    private
    def container_name
      context.container_name
    end

    def volume_search
      context.volume_search
    end

    def container_volumes(container_name:)
      container_metadata = self.task_metadata['Containers'].find do |container|
        container['Name'] == container_name
      end

      return {} if container_metadata.nil?

      container_metadata['Volumes']
    end

    def task_metadata
      return @task_metadata if defined?(@task_metadata)

      begin
        response = Excon.get(
          "#{ENV['ECS_CONTAINER_METADATA_URI_V4']}/task",
          expects: [200],
          connect_timeout: 5,
          read_timeout: 5,
          write_timeout: 5,
          tcp_nodelay: true
        )

        Logger.debug "Metadata result:"
        Logger.debug(response.body)
        Logger.debug "\n"

        @task_metadata = JSON.parse(response.body)
      rescue
        Logger.info "Metadata uri failed"
        {}
      end
    end
  end
end
