require 'shipitron'
require 'metaractor'
require 'shipitron/consul_lock'
require 'shipitron/server/pull_git_repo'
require 'shipitron/server/build_docker_image'
require 'shipitron/server/push_docker_image'
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

      around do |interactor|
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
        PullGitRepo,
        BuildDockerImage,
        PushDockerImage,
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
