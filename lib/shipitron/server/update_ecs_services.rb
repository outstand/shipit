require 'shipitron'
require 'shipitron/ecs_client'
require 'shipitron/parse_templates'

module Shipitron
  module Server
    class UpdateEcsServices
      include Metaractor
      include EcsClient

      required :region
      required :clusters
      optional :ecs_services
      required :ecs_task_defs
      optional :ecs_service_templates

      before do
        context.ecs_services ||= []
        context.ecs_service_templates ||= []
      end

      def call
        if ecs_services.empty?
          Logger.info 'No ECS services to update.'
          return
        end

        Logger.info "Updating ECS services [#{ecs_services.join(', ')}] with task definitions [#{ecs_task_defs.map(&:to_s).join(', ')}]"

        begin
          clusters.each do |cluster_name|
            service_templates = ParseTemplates.call!(
              templates: ecs_service_templates,
              template_context: {
                cluster: cluster_name,
                revision: nil,
                count: nil
              }
            ).parsed_templates

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
              ecs_task_def = ecs_task_defs.find {|task| task.name == response.task_definition.family }
              service_task_defs[service.service_name] = ecs_task_def
            end

            service_task_defs.each do |ecs_service, ecs_task_def|
              Logger.info "#{cluster_name}: Updating #{ecs_service} with #{ecs_task_def}"

              service_params = {
                cluster: cluster_name,
                service: ecs_service,
                task_definition: ecs_task_def.name_with_revision
              }

              template = service_templates.find {|t| t.service_name == ecs_service }
              if template != nil
                if template.deployment_configuration != nil
                  Logger.debug "Merging deployment config: #{template.deployment_configuration}"
                  service_params.merge(
                    deployment_configuration: template.deployment_configuration
                  )
                end
              end

              ecs_client(region: region).update_service(service_params)
            end
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

      def clusters
        context.clusters
      end

      def ecs_services
        context.ecs_services
      end

      def ecs_task_defs
        context.ecs_task_defs
      end

      def ecs_service_templates
        context.ecs_service_templates
      end
    end
  end
end
