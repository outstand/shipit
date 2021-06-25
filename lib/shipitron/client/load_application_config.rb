require 'shipitron'
require 'shipitron/client'
require 'shipitron/post_build'
require 'aws-sdk-core'

module Shipitron
  module Client
    class LoadApplicationConfig
      include Metaractor

      required :application

      def call
        context.repository_url = config.repository
        context.repository_branch = config.repository_branch
        context.registry = config.registry
        context.s3_cache_bucket = config.cache_bucket
        context.build_cache_location = config.build_cache_location
        context.image_name = config.image_name
        context.named_tag = begin
                              if config.named_tag.nil?
                                'latest'
                              else
                                config.named_tag
                              end
                            end
        context.skip_push = config.skip_push
        context.build_script = config.build_script
        context.post_builds = begin
                                if config.post_builds.nil?
                                  []
                                else
                                  config.post_builds.map {|pb| PostBuild.new(pb) }
                                end
                              end
        context.cluster_discovery = config.cluster_discovery
        context.shipitron_task = config.shipitron_task
        context.ecs_task_defs = config.ecs_task_defs
        context.ecs_services = config.ecs_services
        context.ecs_task_def_dir = config.ecs_task_def_dir
        context.ecs_service_dir = config.ecs_service_dir

        if Shipitron.config.aws_access_key_id? && Shipitron.config.aws_secret_access_key
          Aws.config.update(
            region: "???", # TODO
            credentials: Aws::Credentials.new(
              Shipitron.config.aws_access_key_id,
              Shipitron.config.aws_secret_access_key
            )
          )
        end
      end

      private
      def application
        context.application
      end

      def config
        @config ||= Shipitron.config.applications[application]
      end
    end
  end
end
