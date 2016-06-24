require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Server
    class RegisterEcsTaskDefinition
      include Metaractor
      include EcsClient

      required :region
      required :image_name
      required :image_name_with_tag
      required :ecs_tasks

      def call
        Logger.info "Updating ECS task definitions [#{ecs_tasks.map(&:name).join(', ')}] with image #{image_name_with_tag}"

        begin
          ecs_tasks.each do |ecs_task|
            existing_task = ecs_client(region: region).describe_task_definition(
              task_definition: ecs_task.name
            ).task_definition

            updated_image = false
            existing_task.container_definitions.each do |container_def|
              container_def.image.match(/([^:]+)(?::.+)?/) do |m|
                if m[1] == image_name
                  container_def.image = image_name_with_tag
                  updated_image = true
                end
              end
            end

            unless updated_image
              fail_with_error!(
                message: "Unable to update ECS task definition; #{image_name} not found in task family #{ecs_task.name}."
              )
            end

            existing_task = existing_task.to_h

            ecs_task.revision = ecs_client(region: region).register_task_definition(
              [
                :family,
                :container_definitions,
                :volumes
              ].each_with_object({}) { |k, hash| hash[k] = existing_task[k] if existing_task.has_key?(k) }
            ).task_definition.revision

            Logger.info "Created task definition #{ecs_task}"
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

      def image_name
        context.image_name
      end

      def image_name_with_tag
        context.image_name_with_tag
      end

      def ecs_tasks
        context.ecs_tasks
      end
    end
  end
end
