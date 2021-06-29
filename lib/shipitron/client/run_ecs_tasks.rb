require 'shipitron'
require 'shipitron/client'
require 'shipitron/ecs_client'
require 'shipitron/client/generate_deploy'
require 'shellwords'
require 'base64'
require 'tty-table'
require 'pastel'
require 'securerandom'

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
      optional :simulate_store_deploy
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

        @cluster = clusters.first

        begin
          if simulate?
            server_deploy_opts
            generate_deploy! if context.simulate_store_deploy == true

            return
          end

          generate_deploy!

          response = ecs_client(region: @cluster.region).run_task(
            cluster: @cluster.name,
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
            started_by: Shipitron::Client.started_by
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

        @_deploy_id = SecureRandom.uuid
      end

      def generate_deploy!
        Shipitron::Client::GenerateDeploy.call!(
          server_deploy_opts: server_deploy_opts,
          deploy_id: deploy_id
        )
      end

      def command_args(deploy_id:)
        [
          'server_deploy',
          '--deploy-id', deploy_id
        ]
      end

      def server_deploy_opts
        return @_server_deploy_opts if defined?(@_server_deploy_opts)

        @_server_deploy_opts =
          {
            name: context.application,
            repository: context.repository_url,
            bucket: context.s3_cache_bucket,
            build_cache_location: context.build_cache_location,
            image_name: context.image_name,
            named_tag: context.named_tag,
            region: @cluster.region
          }.tap do |opts|
            opts[:clusters] =
              context.clusters.map(&:name)

            opts[:ecs_task_defs] =
              context.ecs_task_defs

            unless context.ecs_services.empty?
              opts[:ecs_services] =
                context.ecs_services
            end

            if context.registry != nil
              opts[:registry] = context.registry
            end

            if context.build_script != nil
              opts[:build_script] = context.build_script
            end

            if context.skip_push != nil
              opts[:skip_push] = context.skip_push.to_s
            end

            if !context.post_builds.empty?
              opts[:post_builds] =
                context.post_builds.map(&:to_s)
            end

            if !context.ecs_task_def_templates.empty?
              opts[:ecs_task_def_templates] =
                context.ecs_task_def_templates.map do |name, data|
                  if context.ecs_task_defs.include?(name)
                    Base64.urlsafe_encode64(data)
                  end
                end.compact
            end

            if !context.ecs_service_templates.empty?
              opts[:ecs_service_templates] =
                context.ecs_service_templates.map do |name, data|
                  if context.ecs_services.include?(name)
                    Base64.urlsafe_encode64(data)
                  end
                end.compact
            end

            unless context.repository_branch.nil?
              opts[:repository_branch] = context.repository_branch
            end

            if simulate?
              Logger.info "server_deploy opts:\n#{JSON.pretty_generate(opts)}"
            else
              Logger.debug "server_deploy opts:\n#{JSON.pretty_generate(opts)}"
            end
          end
      end

      def simulate?
        context.simulate == true || context.simulate_store_deploy == true
      end
    end
  end
end
