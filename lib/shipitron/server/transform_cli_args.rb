require 'shipitron'
require 'shipitron/docker_image'
require 'shipitron/ecs_task_def'
require 'shipitron/post_build'
require 'base64'

module Shipitron
  module Server
    class TransformCliArgs
      include Metaractor

      required :application
      required :repository_url
      optional :repository_branch
      required :s3_cache_bucket
      required :image_name
      required :region
      required :cluster_name
      required :ecs_task_defs
      optional :ecs_task_def_templates
      required :ecs_services
      optional :ecs_service_templates
      optional :build_script
      optional :post_builds

      before do
        context.ecs_task_def_templates ||= []
        context.ecs_service_templates ||= []
      end

      def call
        cli_args = Smash.new

        %i[
          application
          repository_url
          repository_branch
          s3_cache_bucket
          region
          cluster_name
          ecs_services
          build_script
        ].each_with_object(cli_args) { |k, args| args[k] = context[k] }

        cli_args.docker_image = DockerImage.new(name: context.image_name)

        cli_args.ecs_task_defs = []
        ecs_task_defs.each do |task_def|
          cli_args.ecs_task_defs << EcsTaskDef.new(name: task_def)
        end

        cli_args.ecs_task_def_templates = []
        context.ecs_task_def_templates.each do |template|
          cli_args.ecs_task_def_templates << Base64.urlsafe_decode64(template)
        end

        cli_args.ecs_service_templates = []
        context.ecs_service_templates.each do |template|
          cli_args.ecs_service_templates << Base64.urlsafe_decode64(template)
        end

        Logger.debug "task_def_templates: #{cli_args.ecs_task_def_templates}"
        Logger.debug "service_templates: #{cli_args.ecs_service_templates}"

        if post_builds != nil && !post_builds.empty?
          cli_args.post_builds = []
          post_builds.each do |post_build_str|
            cli_args.post_builds << PostBuild.parse(post_build_str)
          end
        end

        context.cli_args = cli_args
      end

      private
      def ecs_task_defs
        context.ecs_task_defs
      end

      def post_builds
        context.post_builds
      end
    end
  end
end
