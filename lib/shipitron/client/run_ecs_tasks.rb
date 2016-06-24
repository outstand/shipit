require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Client
    class RunEcsTasks
      include Metaractor
      include EcsClient

      required :application
      required :clusters, :ecs_task

      def call
        clusters.each do |cluster|
          begin
            response = ecs_client(region: cluster.region).run_task(
              cluster: cluster.name,
              task_definition: ecs_task,
              overrides: {
                container_overrides: [
                  {
                    name: 'shipitron',
                    command: ['server_deploy', application]
                  }
                ]
              },
              count: 1,
              started_by: 'shipitron'
            )

            if !response.failures.empty?
              response.failures.each do |failure|
                fail_with_error! message: "ECS run_task failure: #{failure.arn}: #{failure.reason}"
              end
            end

          rescue Aws::ECS::Errors::ServiceError => e
            fail_with_errors!(messages: [
              "Error: #{e.message}",
              e.backtrace.join("\n")
            ])
          end
        end
      end

      private
      def application
        context.application
      end

      def clusters
        context.clusters
      end

      def ecs_task
        context.ecs_task
      end
    end
  end
end
