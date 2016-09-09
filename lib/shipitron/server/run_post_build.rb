require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Server
    class RunPostBuild
      include Metaractor
      include EcsClient

      required :region
      required :cluster_name
      optional :post_builds

      def call
        return if post_builds.nil? || post_builds.empty?

        Logger.info 'Running post build commands'

        begin
          post_builds.each do |post_build|
            Logger.info "Running #{post_build.command}"
            response = ecs_client(region: region).run_task(
              cluster: cluster_name,
              task_definition: post_build.ecs_task,
              overrides: {
                container_overrides: [
                  {
                    name: post_build.container_name,
                    command: [post_build.command]
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

            task_arn = response.tasks.first.task_arn

            Logger.info 'Waiting for task to finish'
            loop do
              response = ecs_client(region: region).describe_tasks(
                cluster: cluster_name,
                tasks: [task_arn]
              )
              next if response.tasks.empty?
              Logger.info "Task status: #{response.tasks.first.last_status}"
              break if response.tasks.first.last_status == 'STOPPED'.freeze
              sleep 1
            end
          end

        rescue Aws::ECS::Errors::ServiceError => e
          fail_with_errors!(messages: [
            "Error: #{e.message}",
            e.backtrace.join("\n")
          ])
        end
      end

      private
      def post_builds
        context.post_builds
      end

      def region
        context.region
      end

      def cluster_name
        context.cluster_name
      end
    end
  end
end
