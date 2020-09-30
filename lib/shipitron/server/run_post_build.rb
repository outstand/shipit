require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Server
    class RunPostBuild
      include Metaractor
      include EcsClient

      required :region
      required :clusters
      required :git_info
      optional :post_builds

      def call
        return if post_builds.nil? || post_builds.empty?

        Logger.info 'Running post build commands'

        begin
          post_builds.each do |post_build|
            Logger.info "Running #{post_build.command}"
            response = ecs_client(region: region).run_task(
              cluster: clusters.first,
              task_definition: post_build.ecs_task,
              overrides: {
                container_overrides: [
                  {
                    name: post_build.container_name,
                    command: post_build.command_ary,
                    environment: [
                      {
                        name: "GIT_SHA",
                        value: git_info.sha
                      },
                      {
                        name: "GIT_EMAIL",
                        value: git_info.email
                      },
                      {
                        name: "GIT_NAME",
                        value: git_info.name
                      },
                      {
                        name: "GIT_MESSAGE",
                        value: git_info.summary
                      },
                      {
                        name: "GIT_TIMESTAMP",
                        value: git_info.timestamp
                      },
                      {
                        name: "GIT_BRANCH",
                        value: git_info.branch
                      },
                      {
                        name: "GIT_TAG",
                        value: git_info.tag
                      }
                    ]
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
                cluster: clusters.first,
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

      def clusters
        context.clusters
      end

      def git_info
        context.git_info
      end
    end
  end
end
