require "aws-sdk-s3"

module Shipitron
  module S3Client
    def s3_client
      return @s3_client if defined?(@s3_client)

      @s3_client =
        Aws::S3::Client.new
    end
  end
end
