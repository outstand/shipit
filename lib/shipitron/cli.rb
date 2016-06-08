require 'thor'
require 'shipitron/logger'

module Shipitron
  class CLI < Thor
    desc 'version', 'Print out the version string'
    def version
      require 'shipitron/version'
      say Shipitron::VERSION.to_s
    end

    desc 'deploy <app>', 'Deploys the app'
    option :ember, type: :boolean, default: false
    option :ember_only, type: :boolean, default: false
    def deploy(app)
      $stdout.sync = true
      require 'shipitron/deploy_application'
      result = DeployApplication.call(
        application: app
      )

      if result.failure?
        Logger.fatal 'Deploy failed.'
      end
    end
  end
end
