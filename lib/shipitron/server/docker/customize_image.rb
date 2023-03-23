require 'shipitron'
require 'shipitron/ecs_client'
require 'shipitron/ssm_client'

module Shipitron
  module Server
    module Docker
      class CustomizeImage
        include Metaractor
        include EcsClient
        include SsmClient

        required :region
        required :clusters

        def call
          Logger.info "Customizing docker image"

          overrides = {
            container_overrides: [
              {
                name: "util",
                command: ["echo", "util"]
              }
            ]
          }

          run_task_args = {
            cluster: cluster,
            task_definition: "rails-util-mesh",
            network_configuration: {
              awsvpc_configuration: {
                subnets: awsvpc_private_subnet_ids,
                security_groups: awsvpc_security_group_ids
              }
            },
            overrides:,
            propagate_tags: "TASK_DEFINITION",
            started_by: "shipitron"
          }

          response =
            ecs_client(region: context.region)
            .run_task(run_task_args)

          unless response.failures.empty?
            response.failures.each do |failure|
              fail_with_error! message: "ECS run_task failure: #{failure.arn}: #{failure.reason}"
            end
          end
        end

        private

        def cluster
          context.clusters.first
        end

        def awsvpc_private_subnet_ids
          resp =
            ssm_client(region: context.region)
            .get_parameter(
              name: "/console/#{cluster}/private_subnet_ids"
            )
          JSON.parse(resp.parameter.value)
        end

        def awsvpc_security_group_ids
          resp =
            ssm_client(region: context.region)
            .get_parameter(
              name: "/console/#{cluster}/client_nodes_security_group_ids"
            )
          JSON.parse(resp.parameter.value)
        end
      end
    end
  end
end

