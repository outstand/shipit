require 'shipitron'
require 'diplomat'
require 'shipitron/consul_keys'

module Shipitron
  module Server
    module Git
      class Configure
        include Metaractor
        include ConsulKeys

        required :application
        required :repository_url
        required :s3_cache_bucket

        before do
          configure_consul_client!
        end

        def call
          host_key = fetch_key!(key: "shipitron/#{application}/git_host_key")
          Pathname.new('/home/shipitron/.ssh/known_hosts').open('a') do |file|
            file.puts(host_key.to_s)
          end

          deploy_key = fetch_key!(key: "shipitron/#{application}/git_deploy_key")
          Pathname.new('/home/shipitron/.ssh/id_rsa').open('w') do |file|
            file.puts(deploy_key.to_s)
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
