require "aws-sdk-s3"

module Shipitron
  module S3Client
    def s3_client(region:)
      s3_clients[region]
    end

    private

    def generate_s3_client(region:)
      Aws::S3::Client.new(region:)
    end

    def s3_clients
      return @s3_clients if defined?(@s3_clients)

      @s3_clients = Hash.new do |hash, region|
        hash[region] =
          generate_s3_client(region:)
      end
    end
  end
end
