require "aws-sdk-ssm"

module Shipitron
  module SsmClient
    def ssm_client(region:)
      ssm_clients[region]
    end

    private

    def generate_ssm_client(region:)
      Aws::SSM::Client.new(region:)
    end

    def ssm_clients
      return @ssm_clients if defined?(@ssm_clients)

      @ssm_clients = Hash.new do |hash, region|
        hash[region] =
          generate_ssm_client(region:)
      end
    end
  end
end
