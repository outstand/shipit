require 'shipitron'
require 'shipitron/consul_keys'

module Shipitron
  module Server
    module Docker
      class Configure
        include Metaractor
        include ConsulKeys

        required :application

        before do
          configure_consul_client!
        end

        def call
          return # try no-op
          # username = fetch_scoped_key('docker_user')
          # password = fetch_scoped_key('docker_password')
          #
          # Logger.info `docker login --username #{username} --password #{password}`
          # if $? != 0
          #   fail_with_error!(message: 'Docker login failed.')
          # end
        end

        private
        def application
          context.application
        end

        def fetch_scoped_key(key)
          value = fetch_key(key: "shipitron/#{application}/#{key}")
          value = fetch_key!(key: "shipitron/#{key}") if value.nil?
          value
        end
      end
    end
  end
end
