require 'shipitron'
require 'resolv'

module Shipitron
  module Client
    class FetchClusters
      include Metaractor

      required :cluster_discovery

      def call
        Resolv::DNS.open do |dns|
          resources = dns.getresources(
            context.cluster_discovery,
            Resolv::DNS::Resource::IN::SRV
          ).sort_by! do |a|
            [a.priority, a.weight]
          end.reverse!

          context.clusters = resources.map do |r|
            Smash.new(
              name: r.target[0].to_s,
              region: r.target[1].to_s
            )
          end

          Logger.debug "Clusters: #{context.clusters.inspect}"
        end
      end
    end
  end
end
