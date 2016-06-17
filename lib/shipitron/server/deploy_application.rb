require 'shipitron'
require 'metaractor'
require 'shipitron/consul_lock'
require 'shipitron/server/git/pull_repo'
require 'shipitron/server/docker/configure'
require 'shipitron/server/docker/build_image'
require 'shipitron/server/docker/push_image'
require 'shipitron/server/register_ecs_task_definition'
require 'shipitron/server/migrate_database'
require 'shipitron/server/update_ecs_service'

module Shipitron
  module Server
    class DeployApplication
      include Metaractor
      include Interactor::Organizer
      include ConsulLock

      required :application
      required :repository_url
      required :s3_cache_bucket
      required :image_name

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
        RegisterEcsTaskDefinition,
        MigrateDatabase,
        UpdateEcsService
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
