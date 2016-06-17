require 'shipitron'
require 'metaractor'

module Shipitron
  module Server
    module Docker
      class RunBuildScript
        include Metaractor

        required :application
        required :image_name
        required :git_sha

        def call
          Logger.info 'Building docker image'

          image_name_with_tag = "#{image_name}:#{git_sha}"

          FileUtils.cd("/home/shipitron/#{application}") do
            unless Pathname.new('shipitron/build.sh').exist?
              fail_with_error!(message: 'shipitron/build.sh does not exist')
            end
            Logger.info `shipitron/build.sh #{image_name_with_tag}`
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
      end
    end
  end
end
