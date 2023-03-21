require 'shipitron'
require 'shipitron/client'
require 'resolv'

module Shipitron
  module Client
    class FetchClusters
      include Metaractor

      required :cluster_discovery

      def call
        resources = dns_resources.sort! do |a,b|
          (a.priority <=> b.priority).yield_self do |prio|
            if prio == 0
              b.weight <=> a.weight
            else
              prio
            end
          end
        end

        context.clusters = resources.map do |r|
          Smash.new(
            name: r.target[0].to_s,
            region: r.target[1].to_s
          )
        end

        Logger.debug "Clusters: #{context.clusters.inspect}"
      end

      private

      def dns_resources
        Resolv::DNS.open do |dns|
          dns.getresources(
            context.cluster_discovery,
            Resolv::DNS::Resource::IN::SRV
          )
        end
      end
    end
  end
end
