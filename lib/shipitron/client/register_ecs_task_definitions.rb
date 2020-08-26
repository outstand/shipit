require 'shipitron'
require 'shipitron/client'
require 'shipitron/ecs_client'
require 'shipitron/mustache_yaml_parser'

module Shipitron
  module Client
    class RegisterEcsTaskDefinitions
      include Metaractor
      include EcsClient

      required :region
      required :task_def_directory

      def call
        Logger.info 'Creating ECS task definitions'

        task_defs = Pathname.new(task_def_directory)
        unless task_defs.directory?
          fail_with_error!(
            message: "task definition directory '#{task_def_directory}' does not exist"
          )
        end

        task_defs.find do |path|
          next if path.directory?

          task_def = Smash.load(
            path.to_s,
            parser: MustacheYamlParser.new(
              context: {
                tag: 'latest'
              }
            )
          )

          begin
            ecs_client(region: region).describe_task_definition(
              task_definition: task_def.family
            )
          rescue Aws::ECS::Errors::ClientException => e
            raise if e.message != 'Unable to describe task definition.'

            Logger.info "Creating task definition '#{task_def.family}'"
            Logger.debug "Task definition: #{task_def.to_h}"
            ecs_client(region: region).register_task_definition(
              task_def.to_h
            )
          else
            Logger.info "Task definition '#{task_def.family}' already exists."
          end
        end

        Logger.info 'Done'
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

      def cluster_name
        context.cluster_name
      end

      def task_def_directory
        context.task_def_directory
      end
    end
  end
end
