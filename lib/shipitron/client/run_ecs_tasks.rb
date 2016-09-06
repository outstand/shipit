require 'shipitron'
require 'shipitron/ecs_client'
require 'shellwords'
require 'base64'

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
      optional :ecs_task_def_templates
      required :ecs_services
      optional :ecs_service_templates
      optional :build_script
      optional :post_builds
      optional :simulate
      optional :repository_branch

      before do
        context.post_builds ||= []
        context.ecs_task_def_templates ||= []
        context.ecs_service_templates ||= []
      end

      def call
        Logger.info "Skipping ECS run_task calls due to --simulate" if simulate?

        clusters.each do |cluster|
          begin
            if simulate?
              command_args(cluster)
              next
            end

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
          ary.concat(context.ecs_task_defs.each {|s| escape(s)})

          ary << '--ecs-services'
          ary.concat(context.ecs_services.each {|s| escape(s)})

          if context.build_script != nil
            ary.concat ['--build-script', escaped(:build_script)]
          end

          if !context.post_builds.empty?
            ary << '--post-builds'
            ary.concat(context.post_builds.map(&:to_s).each {|s| escape(s)})
          end

          if !context.ecs_task_def_templates.empty?
            ary << '--ecs-task-def-templates'
            ary.concat(context.ecs_task_def_templates.map {|t| Base64.urlsafe_encode64(t)})
          end

          if !context.ecs_service_templates.empty?
            ary << '--ecs-service-templates'
            ary.concat(context.ecs_service_templates.map {|t| Base64.urlsafe_encode64(t)})
          end

          unless context.repository_branch.nil?
            ary.concat ['--repository-branch', escaped(:repository_branch)]
          end

          if simulate?
            Logger.info "server_deploy command: #{ary.join(' ')}"
          else
            Logger.debug "server_deploy command: #{ary.join(' ')}"
          end
        end
      end

      def simulate?
        context.simulate == true
      end
    end
  end
end
