require 'shipitron'
require 'shipitron/ecs_client'
require 'shellwords'

module Shipitron
  module Client
    class RunEcsTasks
      include Metaractor
      include EcsClient

      required :application
      required :clusters
      required :shipitron_task
      required :repository_url
      required :s3_cache_bucket
      required :image_name
      required :ecs_task_defs
      required :ecs_services
      optional :build_script
      optional :post_builds

      def call
        clusters.each do |cluster|
          begin
            response = ecs_client(region: cluster.region).run_task(
              cluster: cluster.name,
              task_definition: shipitron_task,
              overrides: {
                container_overrides: [
                  {
                    name: 'shipitron',
                    command: command_args(cluster)
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

      def shipitron_task
        context.shipitron_task
      end

      def escape(str)
        Shellwords.escape(str)
      end

      def escaped(sym)
        escape(context[sym])
      end

      def command_args(cluster)
        [
          'server_deploy',
          '--name', escaped(:application),
          '--repository', escaped(:repository_url),
          '--bucket', escaped(:s3_cache_bucket),
          '--image-name', escaped(:image_name),
          '--region', escape(cluster.region),
          '--cluster-name', escape(cluster.name),
        ].tap do |ary|
          ary << '--ecs-task-defs'
          ary.concat context.ecs_task_defs.each {|s| escape(s)}

          ary << '--ecs-services'
          ary.concat context.ecs_services.each {|s| escape(s)}

          if context.build_script != nil
            ary.concat ['--build-script', escaped(:build_script)]
          end

          if context.post_builds != nil
            ary << '--post-builds'
            ary.concat context.post_builds.map(&:to_s).each {|s| escape(s)}
          end

          Logger.debug "command_args: #{ary.inspect}"
        end
      end
    end
  end
end
