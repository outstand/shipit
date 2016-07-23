require 'shipitron'
require 'yaml'
require 'mustache'

module Shipitron
  module Server
    module EcsTaskDefs
      class ParseTemplates
        include Metaractor

        required :ecs_task_def_templates
        required :template_context

        def call
          parsed = []
          ecs_task_def_templates.each do |template|
            parsed << Smash.new(YAML.load(Mustache.render(template, template_context)))
          end

          context.parsed_templates = parsed
        end

        private
        def ecs_task_def_templates
          context.ecs_task_def_templates
        end

        def template_context
          context.template_context
        end
      end
    end
  end
end
