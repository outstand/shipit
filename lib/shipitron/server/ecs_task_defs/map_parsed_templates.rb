require 'shipitron'

module Shipitron
  module Server
    module EcsTaskDefs
      class MapParsedTemplates
        include Metaractor

        required :ecs_task_defs
        required :parsed_templates

        def call
          parsed_templates.each do |parsed|
            task_def = ecs_task_defs.find {|t| t.name == parsed.family }
            next if task_def.nil?
            task_def.params = parsed
          end
        end

        private
        def ecs_task_defs
          context.ecs_task_defs
        end

        def parsed_templates
          context.parsed_templates
        end
      end
    end
  end
end
