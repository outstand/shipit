require 'shipitron'
require 'shipitron/ecs_client'
require 'shipitron/mustache_yaml_parser'
require 'securerandom'

module Shipitron
  module Client
    class CreateEcsServices
      include Metaractor
      include EcsClient

      required :region
      required :service_directory
      required :cluster_name
      required :service_count

      def call
        Logger.info 'Creating ECS services'

        service_defs = Pathname.new(service_directory)
        unless service_defs.directory?
          fail_with_error!(
            message: "service directory '#{service_directory}' does not exist"
          )
        end

        service_defs.find do |path|
          next if path.directory?

          service_def = Smash.load(
            path.to_s,
            parser: MustacheYamlParser.new(
              context: {
                cluster: cluster_name,
                revision: nil, # ECS will default to latest ACTIVE
                count: service_count
              }
            )
          ).merge(
            client_token: SecureRandom.uuid
          )

          Logger.info "Creating service '#{service_def.service_name}'"
          Logger.debug "Service definition: #{service_def.to_h}"
          begin
            ecs_client(region: region).create_service(
              service_def.to_h
            )
          rescue Aws::ECS::Errors::InvalidParameterException => e
            raise if e.message != 'Creation of service was not idempotent.'

            Logger.info "Service '#{service_def.service_name}' already exists."
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

      def service_directory
        context.service_directory
      end

      def cluster_name
        context.cluster_name
      end

      def service_count
        context.service_count
      end
    end
  end
end
