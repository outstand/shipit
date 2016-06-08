require 'shipitron'
require 'metaractor'
require 'shipitron/logger'
require 'shipitron/ecs_client'
require 'shipitron/load_application_config'
require 'shipitron/ensure_deploy_not_running'
require 'shipitron/run_ecs_tasks'

module Shipitron
  class DeployApplication
    include Metaractor
    include Interactor::Organizer

    required :application

    organize [
      LoadApplicationConfig,
      EnsureDeployNotRunning,
      RunEcsTasks
    ]

    def call
      Logger.info "==> Deploying #{application}"
      super
      Logger.info "==> Done"
    end

    private
    def application
      context.application
    end
  end
end
