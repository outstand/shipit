require 'shipitron'
require 'shipitron/post_build'

module Shipitron
  module Client
    class LoadApplicationConfig
      include Metaractor

      required :application

      def call
        context.repository_url = config.repository
        context.s3_cache_bucket = config.cache_bucket
        context.image_name = config.image_name
        context.build_script = config.build_script
        context.post_builds = config.post_builds.map {|pb| PostBuild.new(pb) }
        context.clusters = config.ecs_clusters
        context.shipitron_task = config.shipitron_task
        context.ecs_task_defs = config.ecs_task_defs
        context.ecs_services = config.ecs_services
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
