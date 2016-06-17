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
    option :debug, type: :boolean, default: false
    def deploy(app)
      $stdout.sync = true
      if options[:debug] == false
        Logger.level = :info
      end

      require 'shipitron/client/deploy_application'
      result = Client::DeployApplication.call(
        application: app
      )

      if result.failure?
        result.errors.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Deploy failed.'
      end
    end

    desc 'server_deploy <app>', 'Server-side component of deploy'
    option :name, required: true
    option :repository, required: true
    option :bucket, required: true
    option :image_name, required: true
    option :debug, type: :boolean, default: false
    def server_deploy
      $stdout.sync = true
      if options[:debug] == false
        Logger.level = :info
      end

      require 'shipitron/server/deploy_application'
      result = Server::DeployApplication.call(
        application: options[:name],
        repository_url: options[:repository],
        s3_cache_bucket: options[:bucket],
        image_name: options[:image_name]
      )

      if result.failure?
        result.errors.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Deploy failed.'
      end
    end
  end
end
