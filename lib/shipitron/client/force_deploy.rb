require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Client
    class ForceDeploy
      include Metaractor
      include Interactor::Organizer
      include EcsClient

      required :application

      organize [
        LoadApplicationConfig,
        FetchClusters,
        EnsureDeployNotRunning
      ]

      def call
        Logger.info "==> Force deploying #{application}"

        super

        context.clusters ||= []
        context.ecs_services ||= []

        begin
          context.clusters.each do |cluster|
            context.ecs_services.each do |service|
              ecs_client(region: cluster.region).update_service(
                cluster: cluster.name,
                service: service,
                force_new_deployment: true
              )
            end
          end
        rescue Aws::ECS::Errors::ServiceError => e
          fail_with_errors!(messages: [
            "Error: #{e.message}",
            e.backtrace.join("\n")
          ])
        end

        Logger.info "==> Done"
      end

      private
      def application
        context.application
      end

    end
  end
end
