require 'shipitron'
require 'shipitron/ecs_client'

module Shipitron
  module Server
    module EcsTaskDefs
      class UpdateFromParams
        include Metaractor
        include EcsClient

        required :region
        required :ecs_task_defs

        def call
          ecs_task_defs.each do |ecs_task_def|
            next if ecs_task_def.params.nil?

            ecs_task_def.revision = ecs_client(region: region).register_task_definition(
              ecs_task_def.params.to_h
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
