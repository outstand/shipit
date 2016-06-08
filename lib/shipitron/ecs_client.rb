require 'aws-sdk'

module Shipitron
  module EcsClient
    def ecs_client(region:)
      @ecs_clients ||= {}
      @ecs_clients[region] ||= generate_ecs_client(region: region)
    end

    def generate_ecs_client(region:)
      options = {region: region}
      if Shipitron.config.aws_access_key_id? && Shipitron.config.aws_secret_access_key
        options.merge!(
          access_key_id: Shipitron.config.aws_access_key_id,
          secret_access_key: Shipitron.config.aws_secret_access_key
        )
      end

      Aws::ECS::Client.new(options)
    end
  end
end
