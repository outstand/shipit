require 'shipitron'
require 'shipitron/server/ecs_task_defs/parse_templates'
require 'shipitron/server/ecs_task_defs/map_parsed_templates'
require 'shipitron/server/ecs_task_defs/update_from_params'
require 'shipitron/server/ecs_task_defs/update_in_place'

module Shipitron
  module Server
    class UpdateEcsTaskDefinitions
      include Metaractor
      include Interactor::Organizer

      required :region
      required :docker_image
      required :ecs_task_defs
      optional :ecs_task_def_templates

      before do
        context.ecs_task_def_templates ||= []
        context.template_context = { tag: docker_image.tag }
      end

      organize [
        EcsTaskDefs::ParseTemplates,
        EcsTaskDefs::MapParsedTemplates,
        EcsTaskDefs::UpdateFromParams,
        EcsTaskDefs::UpdateInPlace
      ]

      def call
        Logger.info "Updating ECS task definitions [#{ecs_task_defs.map(&:name).join(', ')}] with image #{docker_image}"
        super
        Logger.info 'Done'
      end

      private
      def docker_image
        context.docker_image
      end

      def ecs_task_defs
        context.ecs_task_defs
      end
    end
  end
end
