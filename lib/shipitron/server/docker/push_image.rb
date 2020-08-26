require 'shipitron'

module Shipitron
  module Server
    module Docker
      class PushImage
        include Metaractor

        required :docker_image
        required :named_tag
        optional :skip_push, default: false

        def call
          return if context.skip_push

          Logger.info "Pushing docker image #{docker_image} and #{docker_image.name_with_tag(named_tag)}"

          Logger.info `docker tag #{docker_image} #{docker_image.name_with_tag(named_tag)}`
          if $? != 0
            fail_with_error!(message: 'Docker tag failed.')
          end

          Logger.info `docker push #{docker_image}`
          if $? != 0
            fail_with_error!(message: 'Docker push failed.')
          end

          Logger.info `docker push #{docker_image.name_with_tag(named_tag)}`
          if $? != 0
            fail_with_error!(message: "Docker push (#{named_tag}) failed.")
          end
        end

        private
        def docker_image
          context.docker_image
        end

        def named_tag
          context.named_tag
        end
      end
    end
  end
end
