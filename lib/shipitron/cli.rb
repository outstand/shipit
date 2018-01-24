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
    option :debug, type: :boolean, default: false
    option :simulate, type: :boolean, default: false
    def deploy(app)
      setup(
        config_file: options[:config_file],
        secrets_file: options[:secrets_file]
      )

      require 'shipitron/client/deploy_application'
      result = Client::DeployApplication.call(
        application: app,
        simulate: options[:simulate]
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
    option :repository_branch, default: 'master'
    option :bucket, required: true
    option :image_name, required: true
    option :named_tag, default: 'latest'
    option :region, required: true
    option :clusters, type: :array, required: true
    option :ecs_task_defs, type: :array, required: true
    option :ecs_task_def_templates, type: :array, default: []
    option :ecs_services, type: :array, default: []
    option :ecs_service_templates, type: :array, default: []
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
        repository_branch: options[:repository_branch],
        s3_cache_bucket: options[:bucket],
        image_name: options[:image_name],
        named_tag: options[:named_tag],
        region: options[:region],
        clusters: options[:clusters],
        ecs_task_defs: options[:ecs_task_defs],
        ecs_task_def_templates: options[:ecs_task_def_templates],
        ecs_services: options[:ecs_services],
        ecs_service_templates: options[:ecs_service_templates],
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

    desc 'bootstrap <app>', 'Bootstrap ECS task definitions and services'
    option :region, required: true
    option :cluster_name, required: true
    option :service_count, type: :numeric, default: 0
    option :task_def_dir, default: 'shipitron/ecs_task_defs'
    option :service_dir, default: 'shipitron/ecs_services'
    option :secrets_file, default: 'shipitron/secrets.yml'
    option :debug, type: :boolean, default: false
    def bootstrap(app)
      setup(
        secrets_file: options[:secrets_file]
      )

      require 'shipitron/client/bootstrap_application'
      result = Client::BootstrapApplication.call(
        application: app,
        region: options[:region],
        cluster_name: options[:cluster_name],
        service_count: options[:service_count],
        task_def_directory: options[:task_def_dir],
        service_directory: options[:service_dir]
      )

      if result.failure?
        result.errors.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Bootstrap failed.'
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
