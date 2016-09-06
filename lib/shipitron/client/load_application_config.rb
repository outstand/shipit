require 'shipitron'
require 'shipitron/post_build'

module Shipitron
  module Client
    class LoadApplicationConfig
      include Metaractor

      required :application

      def call
        context.repository_url = config.repository
        context.repository_branch = config.repository_branch
        context.s3_cache_bucket = config.cache_bucket
        context.image_name = config.image_name
        context.build_script = config.build_script
        context.post_builds = begin
                                if config.post_builds.nil?
                                  []
                                else
                                  config.post_builds.map {|pb| PostBuild.new(pb) }
                                end
                              end
        context.clusters = config.ecs_clusters
        context.shipitron_task = config.shipitron_task
        context.ecs_task_defs = config.ecs_task_defs
        context.ecs_services = config.ecs_services
        context.ecs_task_def_dir = config.ecs_task_def_dir
        context.ecs_service_dir = config.ecs_service_dir
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
