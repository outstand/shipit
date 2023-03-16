require 'shipitron'
require 'shipitron/consul_keys'

module Shipitron
  module Server
    class UpdateDeployRef
      include Metaractor
      include ConsulKeys

      required :application
      required :docker_image

      def call
        Logger.info "Updating deploy ref to #{docker_image.tag}"
        set_key!(key: deploy_ref_key, value: docker_image.tag)
      end

      private

      def application
        context.application
      end

      def docker_image
        context.docker_image
      end

      def deploy_ref_key
        key = fetch_key(key: "shipitron/#{application}/deploy_ref_key")
        if key.nil?
          key = "shipitron/#{application}/deploy_ref"
          Logger.info "Defaulting deploy_ref_key to #{key}"
        end
        key
      end
    end
  end
end
