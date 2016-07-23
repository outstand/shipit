require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Server
    module EcsTaskDefs
      class UpdateInPlace
        include Metaractor
        include EcsClient

        required :region
        required :ecs_task_defs

        def call
          ecs_task_defs.each do |ecs_task_def|
            next if ecs_task_def.params != nil

            existing_task = ecs_client(region: region).describe_task_definition(
              task_definition: ecs_task_def.name
            ).task_definition

            updated_image = false
            existing_task.container_definitions.each do |container_def|
              container_def.image.match(/([^:]+)(?::.+)?/) do |m|
                if m[1] == docker_image.name
                  container_def.image = docker_image.name_with_tag
                  updated_image = true
                end
              end
            end

            unless updated_image
              fail_with_error!(
                message: "Unable to update ECS task definition; #{docker_image.name} not found in task family #{ecs_task_def.name}."
              )
            end

            existing_task = existing_task.to_h

            ecs_task_def.revision = ecs_client(region: region).register_task_definition(
              [
                :family,
                :container_definitions,
                :volumes
              ].each_with_object({}) { |k, hash| hash[k] = existing_task[k] if existing_task.has_key?(k) }
            ).task_definition.revision

            Logger.info "Created task definition #{ecs_task_def}"
          end
        rescue Aws::ECS::Errors::ServiceError => e
          fail_with_errors!(messages: [
            "Error: #{e.message}",
            e.backtrace.join("\n")
          ])
        end

        private
        def region
          context.region
        end

        def ecs_task_defs
          context.ecs_task_defs
        end
      end
    end
  end
end
