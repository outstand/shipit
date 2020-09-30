require 'shipitron'
require 'tty-command'

module Shipitron
  module Server
    module Docker
      class RunBuildScript
        include Metaractor

        required :application
        required :docker_image
        required :git_info
        required :named_tag
        optional :build_script, default: 'shipitron/build.sh'
        optional :registry

        def call
          Logger.info 'Building docker image'

          docker_image.registry = registry if registry != nil
          docker_image.tag = git_info.short_sha

          FileUtils.cd("/home/shipitron/#{application}") do
            unless Pathname.new(build_script).exist?
              fail_with_error!(message: "#{build_script} does not exist")
            end

            cmd = TTY::Command.new
            result = cmd.run!("#{build_script} #{docker_image} #{named_tag}")

            if result.failure?
              fail_with_error!(message: "build script exited with non-zero code: #{result.exit_status}")
            end
          end
        end

        private
        def application
          context.application
        end

        def docker_image
          context.docker_image
        end

        def git_info
          context.git_info
        end

        def named_tag
          context.named_tag
        end

        def build_script
          context.build_script
        end

        def registry
          context.registry
        end
      end
    end
  end
end
