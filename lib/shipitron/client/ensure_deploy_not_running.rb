require 'shipitron'
require 'shipitron/ecs_client'

# Note: This is a best effort client side check to make sure there
# isn't a deploy running.  The server side check has more guarantees.

module Shipitron
  module Client
    class EnsureDeployNotRunning
      include Metaractor
      include EcsClient

      required :clusters
      optional :simulate

      def call
        return if simulate?

        clusters.each do |cluster|
          %w[PENDING RUNNING].each do |status|
            begin
              response = ecs_client(region: cluster.region).list_tasks(
                cluster: cluster.name,
                started_by: 'shipitron',
                max_results: 1,
                desired_status: status
              )
              if !response.task_arns.empty?
                fail_with_errors!(messages: [
                  'Shipitron says "THERE CAN BE ONLY ONE"',
                  'Deploy is already running.'
                ])
              end
            rescue Aws::ECS::Errors::ClusterNotFoundException
              fail_with_errors!(messages: [
                'Shipitron says "PUNY HUMAN IS MISSING A CLUSTER"',
                "Cluster '#{cluster.name}' not found in region #{cluster.region}."
              ])
            end
          end
        end
      end

      private
      def clusters
        context.clusters
      end

      def simulate?
        context.simulate == true
      end
    end
  end
end
