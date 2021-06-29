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
    option :secrets_file, default: '~/.config/shipitron/secrets.yml'
    option :global_config_file, default: '~/.config/shipitron/config.yml'
    option :debug, type: :boolean, default: false
    option :simulate, type: :boolean, default: false
    option :simulate_store_deploy, type: :boolean, default: false
    def deploy(app)
      setup(
        config_file: options[:config_file],
        secrets_file: options[:secrets_file],
        global_config_file: options[:global_config_file]
      )

      require 'shipitron/client/deploy_application'
      result = Client::DeployApplication.call(
        application: app,
        simulate: options[:simulate],
        simulate_store_deploy: options[:simulate_store_deploy]
      )

      if result.failure?
        result.error_messages.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Deploy failed.'
      end
    end

    desc 'force_deploy <app>', 'Forces a redeploy of the app'
    option :config_file, default: 'shipitron/config.yml'
    option :secrets_file, default: '~/.config/shipitron/secrets.yml'
    option :debug, type: :boolean, default: false
    def force_deploy(app)
      setup(
        config_file: options[:config_file],
        secrets_file: options[:secrets_file]
      )

      require 'shipitron/client/force_deploy'
      result = Client::ForceDeploy.call(
        application: app
      )

      if result.failure?
        result.error_messages.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Deploy failed.'
      end
    end


    desc 'server_deploy', 'Server-side component of deploy'
    option :deploy_id, required: true
    def server_deploy
      setup

      if !ENV.key?("SHIPITRON_DEPLOY_BUCKET") || !ENV.key?("SHIPITRON_DEPLOY_BUCKET_REGION")
        raise "Missing shipitron deploy bucket env vars!"
      end

      require 'shipitron/server/fetch_deploy'
      deploy_options = Server::FetchDeploy.call!(
        deploy_bucket: ENV["SHIPITRON_DEPLOY_BUCKET"],
        deploy_bucket_region: ENV["SHIPITRON_DEPLOY_BUCKET_REGION"],
        deploy_id: options[:deploy_id]
      ).deploy_options

      require 'shipitron/server/transform_cli_args'
      cli_args = Server::TransformCliArgs.call!(
        application: deploy_options[:name],
        repository_url: deploy_options[:repository],
        repository_branch: deploy_options[:repository_branch],
        registry: deploy_options[:registry],
        s3_cache_bucket: deploy_options[:bucket],
        build_cache_location: deploy_options[:build_cache_location],
        image_name: deploy_options[:image_name],
        named_tag: deploy_options[:named_tag],
        skip_push: deploy_options[:skip_push],
        region: deploy_options[:region],
        clusters: deploy_options[:clusters],
        ecs_task_defs: deploy_options[:ecs_task_defs],
        ecs_task_def_templates: deploy_options[:ecs_task_def_templates],
        ecs_services: deploy_options[:ecs_services],
        ecs_service_templates: deploy_options[:ecs_service_templates],
        build_script: deploy_options[:build_script],
        post_builds: deploy_options[:post_builds]
      ).cli_args

      require 'shipitron/server/deploy_application'
      result = Server::DeployApplication.call(
        cli_args
      )

      if result.failure?
        result.error_messages.each do |error|
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
    option :secrets_file, default: '~/.config/shipitron/secrets.yml'
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
        result.error_messages.each do |error|
          Logger.fatal error
        end
        Logger.fatal 'Bootstrap failed.'
      end
    end

    private
    def setup(config_file:nil, secrets_file:nil, global_config_file:nil)
      $stdout.sync = true
      if options[:debug] == false
        Logger.level = :info
      end

      Shipitron.config_file = config_file unless config_file.nil?
      Shipitron.secrets_file = secrets_file unless secrets_file.nil?
      Shipitron.global_config_file = global_config_file unless global_config_file.nil?
    end
  end
end
