require 'shipitron'
require 'shipitron/consul_keys'
require 'json'

module Shipitron
  module Server
    module Docker
      class Configure
        include Metaractor
        include ConsulKeys

        required :application
        optional :registry

        before do
          configure_consul_client!
        end

        def call
          username = fetch_scoped_key('docker_user')
          password = fetch_scoped_key('docker_password')

          if username && password
            Logger.info `docker login --username #{username} --password #{password}`
            if $? != 0
              fail_with_error!(message: 'Docker login failed.')
            end
          end

          if registry
            case registry
            when /docker\.io/
              # do nothing
            when /\d+\.dkr\.ecr\.us-east-1\.amazonaws\.com/
              # ECR
              config_file = Pathname.new('/home/shipitron/.docker/config.json')
              config_file.parent.mkpath
              config_file.open('r+b') do |file|
                json = file.read
                hash = JSON.parse(json) rescue {}
                hash['credHelpers'] ||= {}
                hash['credHelpers'][registry] = 'ecr-login'

                file.truncate(0)
                file.puts(JSON.generate(hash))
                file.chmod(0600)
              end
            end
          end
        end

        private
        def application
          context.application
        end

        def registry
          context.registry
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
