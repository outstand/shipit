require 'shipitron'
require 'shipitron/client'
require 'shipitron/client/register_ecs_task_definitions'
require 'shipitron/client/create_ecs_services'

module Shipitron
  module Client
    class BootstrapApplication
      include Metaractor
      include Interactor::Organizer

      required :application
      required :region
      required :cluster_name
      required :service_count
      required :task_def_directory
      required :service_directory

      organize [
        RegisterEcsTaskDefinitions,
        CreateEcsServices
      ]

      def call
        Logger.info "==> Bootstrapping #{application}"
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
