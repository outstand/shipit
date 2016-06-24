require 'shipitron'

module Shipitron
  module Server
    module Docker
      class RunBuildScript
        include Metaractor

        required :application
        required :image_name
        required :git_sha
        optional :build_script

        before do
          context.build_script ||= 'shipitron/build.sh'
        end

        def call
          Logger.info 'Building docker image'

          image_name_with_tag = "#{image_name}:#{git_sha}"

          FileUtils.cd("/home/shipitron/#{application}") do
            unless Pathname.new(build_script).exist?
              fail_with_error!(message: "#{build_script} does not exist")
            end
            Logger.info `#{build_script} #{image_name_with_tag}`
            if $? != 0
              fail_with_error!(message: "build script exited with non-zero code: #{$?}")
            end
          end

          context.image_name_with_tag = image_name_with_tag
        end

        private
        def application
          context.application
        end

        def image_name
          context.image_name
        end

        def git_sha
          context.git_sha
        end

        def build_script
          context.build_script
        end
      end
    end
  end
end
