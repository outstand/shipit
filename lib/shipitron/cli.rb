require 'thor'
require 'shipitron'

module Shipitron
  class CLI < Thor
    desc 'version', 'Print out the version string'
    def version
      require 'shipitron/version'
      say Shipitron::VERSION.to_s
    end

    desc 'deploy <app>', 'Deploys the app'
    option :config_file, default: 'shipitron/config.yml'
    option :secrets_file, default: 'shipitron/secrets.yml'
    option :ember, type: :boolean, default: false
    option :ember_only, type: :boolean, default: false
    option :debug, type: :boolean, default: false
    def deploy(app)
      setup(
        config_file: options[:config_file],
        secrets_file: options[:secrets_file]
      )

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

    desc 'server_deploy', 'Server-side component of deploy'
    option :name, required: true
    option :repository, required: true
    option :bucket, required: true
    option :image_name, required: true
    option :region, required: true
    option :cluster_name, required: true
    option :ecs_tasks, type: :array, required: true
    option :ecs_services, type: :array, required: true
    option :build_script, default: nil
    option :post_builds, type: :array
    option :secrets_file, default: 'shipitron/secrets.yml'
    option :debug, type: :boolean, default: false
    def server_deploy
      setup(
        secrets_file: options[:secrets_file]
      )

      require 'shipitron/server/transform_cli_args'
      cli_args = Server::TransformCliArgs.call!(
        application: options[:name],
        repository_url: options[:repository],
        s3_cache_bucket: options[:bucket],
        image_name: options[:image_name],
        region: options[:region],
        cluster_name: options[:cluster_name],
        ecs_tasks: options[:ecs_tasks],
        ecs_services: options[:ecs_services],
        build_script: options[:build_script],
        post_builds: options[:post_builds]
      ).cli_args

      require 'shipitron/server/deploy_application'
      result = Server::DeployApplication.call(
        cli_args
      )

      if result.failure?
        result.errors.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Deploy failed.'
      end
    end

    private
    def setup(config_file:nil, secrets_file:nil)
      $stdout.sync = true
      if options[:debug] == false
        Logger.level = :info
      end

      Shipitron.config_file = config_file unless config_file.nil?
      Shipitron.secrets_file = secrets_file unless secrets_file.nil?
    end
  end
end
