require 'shipitron'
require 'metaractor'

module Shipitron
  module Server
    class DeployApplication
      include Metaractor
      include Interactor::Organizer

      required :application

      organize [
      ]

      def call
        Logger.info "==> Deploying #{application} (server-side)"
        super
        Logger.info "==> Done"
      end

      private
      def application
        context.application
      end
    end
  end
end
