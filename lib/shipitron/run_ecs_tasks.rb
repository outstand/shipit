require 'shipitron'
require 'metaractor'
require 'shipitron/logger'
require 'shipitron/ecs_client'

module Shipitron
  class RunEcsTasks
    include Metaractor
    include EcsClient

    required :clusters, :ecs_task

    def call
      clusters.each do |cluster|
        begin
          response = ecs_client(region: cluster.region).run_task(
            cluster: cluster.name,
            task_definition: ecs_task,
            count: 1,
            started_by: 'shipitron'
          )

          if !response.failures.empty?
            Logger.error 'ECS API Failure!'
            response.failures.each do |failure|
              Logger.error "#{failure.arn}: #{failure.reason}"
            end
          end

        rescue Aws::ECS::Errors::ServiceError => e
          Logger.error "Error: #{e.message}"
          Logger.error e.backtrace.join("\n")
          context.fail!
        end
      end
    end

    private
    def clusters
      context.clusters
    end

    def ecs_task
      context.ecs_task
    end
  end
end
