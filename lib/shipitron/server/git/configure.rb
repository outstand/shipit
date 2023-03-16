require 'shipitron'
require 'shipitron/consul_keys'

module Shipitron
  module Server
    module Git
      class Configure
        include Metaractor
        include ConsulKeys

        required :application
        required :repository_url

        def call
          host_key = begin
                       key = fetch_key(key: "shipitron/#{application}/git_host_key")
                       key = fetch_key!(key: 'shipitron/git_host_key') if key.nil?
                       key
                     end
          Pathname.new('/home/shipitron/.ssh/known_hosts').open('a') do |file|
            file.puts(host_key.to_s)
          end

          deploy_key = begin
                         key = fetch_key(key: "shipitron/#{application}/git_deploy_key")
                         key = fetch_key!(key: 'shipitron/git_deploy_key') if key.nil?
                         key
                       end
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
