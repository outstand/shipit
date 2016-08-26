require 'shipitron'
require 'shipitron/client/load_deployment_config'
require 'shipitron/client/upload_input_file'
require 'shipitron/client/ensure_deploy_not_running'
require 'shipitron/client/run_ecs_tasks'

module Shipitron
  module Client
    class DeployApplications
      include Metaractor
      include Interactor::Organizer

      required :application_names

      organize [
        LoadDeploymentConfig,
        UploadInputFile,
        # EnsureDeployNotRunning,
        # RunEcsTasks
      ]

      def call
        Logger.info "==> Deploying #{application_names.join(', ')}"
        super
        Logger.info "==> Done"
      end

      private
      def application_names
        context.application_names
      end
    end
  end
end
