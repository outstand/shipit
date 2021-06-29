require 'shipitron'
require 'shipitron/server'
require 'aws-sdk-s3'
require 'json'

module Shipitron
  module Server
    class FetchDeploy
      include Metaractor

      required :deploy_bucket
      required :deploy_bucket_region
      required :deploy_id

      def call
        s3_key = "#{Shipitron::DEPLOY_BUCKET_PREFIX}#{context.deploy_id}"
        Logger.info "Fetching deploy config from s3://#{deploy_bucket}/#{s3_key}"

        client = Aws::S3::Client.new(region: deploy_bucket_region)

        response = client.get_object(
          bucket: deploy_bucket,
          key: s3_key
        )

        context.deploy_options = JSON.parse(response.body.read)
      end

      private

      def deploy_bucket
        context.deploy_bucket
      end

      def deploy_bucket_region
        context.deploy_bucket_region
      end
    end
  end
end
