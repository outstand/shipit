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
        context.post_builds = config.post_builds.map do |pb|
          pb = pb.to_h
          pb.extend(Hashie::Extensions::SymbolizeKeys)
          pb.symbolize_keys!

          PostBuild.new(pb)
        end
        context.clusters = config.ecs_clusters
        context.shipitron_task = config.shipitron_task
        context.ecs_tasks = config.ecs_tasks
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
