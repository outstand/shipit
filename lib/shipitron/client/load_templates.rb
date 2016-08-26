require 'shipitron'
#TODO: remove

module Shipitron
  module Client
    class LoadTemplates
      include Metaractor

      required :ecs_task_def_dir
      required :ecs_service_dir

      def call
        context.ecs_task_def_templates = load_templates(ecs_task_def_dir)
        context.ecs_service_templates = load_templates(ecs_service_dir)
      end

      private
      def ecs_task_def_dir
        context.ecs_task_def_dir
      end

      def ecs_service_dir
        context.ecs_service_dir
      end

      def load_templates(dir)
        search_path = Pathname.new(dir)
        unless search_path.directory?
          fail_with_error!(
            message: "directory '#{dir}' does not exist"
          )
        end

        templates = []
        search_path.find do |path|
          next if path.directory?

          templates << path.read
        end

        Logger.debug "Templates loaded: #{templates.inspect}"
        templates
      end
    end
  end
end
