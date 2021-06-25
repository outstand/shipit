require 'shipitron'
require 'shipitron/client'
require 'shipitron/ecs_client'
require 'shipitron/client/generate_deploy'
require 'shellwords'
require 'base64'
require 'tty-table'
require 'pastel'

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
      required :build_cache_location
      required :image_name
      required :named_tag
      required :ecs_task_defs
      optional :ecs_task_def_templates, default: []
      optional :ecs_services, default: []
      optional :ecs_service_templates, default: []
      optional :build_script
      optional :skip_push
      optional :post_builds, default: []
      optional :simulate
      optional :repository_branch
      optional :registry

      def call
        Logger.info "Skipping ECS run_task calls due to --simulate" if simulate?

        Logger.info "Deploying to:"
        pastel = Pastel.new
        table = TTY::Table.new do |t|
          clusters.each_with_index do |cluster, i|
            if i == 0
              t << [pastel.yellow('*'), cluster.name, cluster.region, '[' + pastel.green('shipitron') + ']']
            else
              t << ['', cluster.name, cluster.region, '']
            end
          end
        end
        table.render.each_line do |line|
          Logger.info line.chomp
        end

        cluster = clusters.first

        begin
          if simulate?
            server_deploy_args(cluster: cluster)
            return
          end

          response = ecs_client(region: cluster.region).run_task(
            cluster: cluster.name,
            task_definition: shipitron_task,
            overrides: {
              container_overrides: [
                {
                  name: 'shipitron',
                  command: command_args(deploy_id: deploy_id)
                }
              ]
            },
            count: 1,
            started_by: Shipitron::Client::STARTED_BY
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

      def deploy_id
        return @_deploy_id if defined?(@_deploy_id)

        result = Shipitron::Client::GenerateDeploy.call!(
          server_deploy_args: server_deploy_args(cluster: cluster)
        )
        @_deploy_id = result.deploy_id
      end

      def command_args(deploy_id:)
        [
          'server_deploy',
          '--deploy-id', deploy_id
        ]
      end

      def server_deploy_args(cluster:)
        return @_server_deploy_args if defined?(@_server_deploy_args)

        @_server_deploy_args =
          [
            'server_deploy',
            '--name', context.application,
            '--repository', context.repository_url,
            '--bucket', context.s3_cache_bucket,
            '--build-cache-location', context.build_cache_location,
            '--image-name', context.image_name,
            '--named-tag', context.named_tag,
            '--region', cluster.region,
          ].tap do |ary|
            ary << '--clusters'
            ary.concat(context.clusters.map(&:name))

            ary << '--ecs-task-defs'
            ary.concat(context.ecs_task_defs)

            unless context.ecs_services.empty?
              ary << '--ecs-services'
              ary.concat(context.ecs_services)
            end

            if context.registry != nil
              ary.concat ['--registry', context.registry]
            end

            if context.build_script != nil
              ary.concat ['--build-script', context.build_script]
            end

            if context.skip_push != nil
              ary.concat ['--skip-push', context.skip_push.to_s]
            end

            if !context.post_builds.empty?
              ary << '--post-builds'
              ary.concat(context.post_builds.map(&:to_s))
            end

            if !context.ecs_task_def_templates.empty?
              ary << '--ecs-task-def-templates'
              ary.concat(
                context.ecs_task_def_templates.map do |name, data|
                  if context.ecs_task_defs.include?(name)
                    Base64.urlsafe_encode64(data)
                  end
                end.compact
              )
            end

            if !context.ecs_service_templates.empty?
              ary << '--ecs-service-templates'
              ary.concat(
                context.ecs_service_templates.map do |name, data|
                  if context.ecs_services.include?(name)
                    Base64.urlsafe_encode64(data)
                  end
                end.compact
              )
            end

            unless context.repository_branch.nil?
              ary.concat ['--repository-branch', context.repository_branch]
            end

            if simulate?
              Logger.info "server_deploy args: #{ary.shelljoin}"
            else
              Logger.debug "server_deploy args: #{ary.shelljoin}"
            end
          end
      end

      def simulate?
        context.simulate == true
      end
    end
  end
end
