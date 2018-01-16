require 'shipitron'
require 'shipitron/client/load_application_config'
require 'shipitron/client/load_templates'
require 'shipitron/client/ensure_deploy_not_running'
require 'shipitron/client/run_ecs_tasks'

module Shipitron
  module Client
    class DeployApplication
      include Metaractor
      include Interactor::Organizer

      required :application
      optional :simulate

      organize [
        LoadApplicationConfig,
        LoadTemplates,
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
end
