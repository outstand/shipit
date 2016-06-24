require 'shipitron'
require 'shipitron/ecs_task'
require 'shipitron/post_build'

module Shipitron
  module Server
    class TransformCliArgs
      include Metaractor

      required :application
      required :repository_url
      required :s3_cache_bucket
      required :image_name
      required :region
      required :cluster_name
      required :ecs_tasks
      required :ecs_services
      optional :build_script
      optional :post_builds

      def call
        cli_args = Hashie::Mash.new

        %i[
          application
          repository_url
          s3_cache_bucket
          image_name
          region
          cluster_name
          ecs_services
          build_script
        ].each_with_object(cli_args) { |k, args| args[k] = context[k] }

        cli_args.ecs_tasks = []
        ecs_tasks.each do |ecs_task|
          cli_args.ecs_tasks << EcsTask.new(name: ecs_task)
        end

        if post_builds != nil && !post_builds.empty?
          cli_args.post_builds = []
          post_builds.each do |post_build_str|
            cli_args.post_builds << PostBuild.parse(post_build_str)
          end
        end

        context.cli_args = cli_args
      end

      private
      def ecs_tasks
        context.ecs_tasks
      end

      def post_builds
        context.post_builds
      end
    end
  end
end
