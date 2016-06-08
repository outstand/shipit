require 'shipitron'
require 'metaractor'

module Shipitron
  class LoadApplicationConfig
    include Metaractor

    required :application

    def call
      context.clusters = clusters
      context.ecs_task = ecs_task
    end

    private
    def application
      context.application
    end

    def config
      @config ||= Shipitron.config.applications[application]
    end

    def clusters
      config.ecs_clusters
    end

    def ecs_task
      config.ecs_task
    end
  end
end
