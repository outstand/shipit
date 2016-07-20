require 'shipitron'

module Shipitron
  module Server
    module Docker
      class PushImage
        include Metaractor

        required :docker_image

        def call
          Logger.info "Pushing docker image #{docker_image} and #{docker_image.name_with_tag(:latest)}"

          Logger.info `docker tag #{docker_image} #{docker_image.name_with_tag(:latest)}`
          if $? != 0
            fail_with_error!(message: 'Docker tag failed.')
          end

          Logger.info `docker push #{docker_image}`
          if $? != 0
            fail_with_error!(message: 'Docker push failed.')
          end

          Logger.info `docker push #{docker_image.name_with_tag(:latest)}`
          if $? != 0
            fail_with_error!(message: 'Docker push (latest) failed.')
          end
        end

        private
        def docker_image
          context.docker_image
        end
      end
    end
  end
end
