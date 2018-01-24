require 'shipitron'
require 'shipitron/ecs_client'
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
      required :image_name
      required :named_tag
      required :ecs_task_defs
      optional :ecs_task_def_templates
      optional :ecs_services
      optional :ecs_service_templates
      optional :build_script
      optional :post_builds
      optional :simulate
      optional :repository_branch

      before do
        context.post_builds ||= []
        context.ecs_task_def_templates ||= {}
        context.ecs_services ||= []
        context.ecs_service_templates ||= {}
      end

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
            command_args(cluster)
            return
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
          '--named-tag', escaped(:named_tag),
          '--region', escape(cluster.region),
        ].tap do |ary|
          ary << '--clusters'
          ary.concat(context.clusters.each {|c| escape(c)})

          ary << '--ecs-task-defs'
          ary.concat(context.ecs_task_defs.each {|s| escape(s)})

          unless context.ecs_services.empty?
            ary << '--ecs-services'
            ary.concat(context.ecs_services.each {|s| escape(s)})
          end

          if context.build_script != nil
            ary.concat ['--build-script', escaped(:build_script)]
          end

          if !context.post_builds.empty?
            ary << '--post-builds'
            ary.concat(context.post_builds.map(&:to_s).each {|s| escape(s)})
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
