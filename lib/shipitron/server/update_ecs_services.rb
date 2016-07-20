require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Server
    class UpdateEcsServices
      include Metaractor
      include EcsClient

      required :region
      required :cluster_name
      required :ecs_services
      required :ecs_task_defs

      def call
        Logger.info "Updating ECS services [#{ecs_services.join(', ')}] with task definitions [#{ecs_task_defs.map(&:to_s).join(', ')}]"

        begin
          service_task_defs = {}

          # Find all requested services
          services_response = ecs_client(region: region).describe_services(
            cluster: cluster_name,
            services: ecs_services
          )

          # For each service, find the task definition it references
          services_response.services.each do |service|
            response = ecs_client(region: region).describe_task_definition(
              task_definition: service.task_definition
            )

            # For the task definition, find the locally updated version in ecs_task_defs
            ecs_task = ecs_task_defs.find {|task| task.name == response.task_definition.family }
            service_task_defs[service.service_name] = ecs_task
          end

          service_task_defs.each do |ecs_service, ecs_task|
            Logger.info "Updating #{ecs_service} with #{ecs_task}"

            ecs_client(region: region).update_service(
              cluster: cluster_name,
              service: ecs_service,
              task_definition: ecs_task.name_with_revision
            )
          end

        rescue Aws::ECS::Errors::ServiceError => e
          fail_with_errors!(messages: [
            "Error: #{e.message}",
            e.backtrace.join("\n")
          ])
        end
      end

      private
      def region
        context.region
      end

      def cluster_name
        context.cluster_name
      end

      def ecs_services
        context.ecs_services
      end

      def ecs_task_defs
        context.ecs_task_defs
      end
    end
  end
end
