require 'hashie'

module Shipitron
  class Application < Hashie::Dash
    property :repository_url, required: true
    property :image_name, required: true
    property :ecs_clusters, required: true
    property :ecs_task_defs, required: true
    property :ecs_task_def_templates
    property :ecs_services
    property :ecs_service_templates
    property :build_script
    property :repository_branch
    property :shipitron_task, default: 'shipitron'
  end
end
