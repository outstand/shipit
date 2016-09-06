require 'shipitron'
require 'shipitron/consul_lock'
require 'shipitron/server/git/pull_repo'
require 'shipitron/server/docker/configure'
require 'shipitron/server/docker/build_image'
require 'shipitron/server/docker/push_image'
require 'shipitron/server/update_ecs_task_definitions'
require 'shipitron/server/run_post_build'
require 'shipitron/server/update_ecs_services'

module Shipitron
  module Server
    class DeployApplication
      include Metaractor
      include Interactor::Organizer
      include ConsulLock

      required :application
      required :repository_url
      required :s3_cache_bucket
      required :docker_image
      required :region
      required :cluster_name
      required :ecs_task_defs
      optional :ecs_task_def_templates
      optional :ecs_services
      optional :ecs_service_templates
      optional :build_script
      optional :post_builds
      optional :repository_branch

      around do |interactor|
        if ENV['CONSUL_HOST'].nil?
          fail_with_error!(message: 'Environment variable CONSUL_HOST required')
        end

        Diplomat.configure do |config|
          config.url = "http://#{ENV['CONSUL_HOST']}:8500"
        end

        begin
          with_lock(key: "shipitron/#{application}/deploy_lock") do
            interactor.call
          end
        rescue UnableToLock
          fail_with_errors!(messages: [
            'Shipitron says: THERE CAN BE ONLY ONE',
            'Unable to acquire deploy lock.'
          ])
        end
      end

      organize [
        Git::PullRepo,
        Docker::Configure,
        Docker::BuildImage,
        Docker::PushImage,
        UpdateEcsTaskDefinitions,
        RunPostBuild,
        UpdateEcsServices
      ]

      def call
        Logger.info "==> Deploying #{application} (server-side)"
        super
        Logger.info "==> Done"
      end

      private
      def application
        context.application
      end
    end
  end
end
