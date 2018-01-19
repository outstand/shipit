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
          docker_auth = begin
                          key = fetch_key(key: "shipitron/#{application}/docker_auth")
                          key = fetch_key!(key: 'shipitron/docker_auth') if key.nil?
                          key
                        end
          auth_file = Pathname.new('/home/shipitron/.docker/config.json')
          auth_file.parent.mkpath
          auth_file.open('wb') do |file|
            file.puts(docker_auth.to_s)
            file.chmod(0600)
          end
        end

        private
        def application
          context.application
        end

      end
    end
  end
end
