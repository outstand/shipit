require 'shipitron'
require 'metaractor'

module Shipitron
  module Server
    module Docker
      class PushImage
        include Metaractor

        required :image_name_with_tag

        def call
          Logger.info "Pushing docker image #{image_name_with_tag}"

          Logger.info `docker push #{image_name_with_tag}`
          if $? != 0
            fail_with_error!(message: 'Docker push failed.')
          end
        end

        private
        def image_name_with_tag
          context.image_name_with_tag
        end
      end
    end
  end
end
