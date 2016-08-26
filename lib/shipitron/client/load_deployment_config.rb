require 'shipitron'
require 'shipitron/application'

module Shipitron
  module Client
    class LoadDeploymentConfig
      include Metaractor

      required :application_names

      def call
        context.deployment_config = deployment_config
      end

      private
      def deployment_config
        Shipitron.config.dup.tap do |config|
          config.applications.select! {|k,v| application_names.include? k }
          config.pre_launch.select! {|v| application_names.include? v }
          config.launch.select! {|v| application_names.include? v }
        end
      end

      def application_names
        context.application_names
      end
    end
  end
end
