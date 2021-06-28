require 'shipitron'
require 'shipitron/client'
require 'shipitron/fetch_bucket'
require 'securerandom'
require 'aws-sdk-s3'

module Shipitron
  module Client
    class GenerateDeploy
      include Metaractor

      required :server_deploy_opts
      required :deploy_id

      def call
        s3_key = "#{Shipitron::DEPLOY_BUCKET_PREFIX}#{context.deploy_id}"
        Logger.info "Uploading deploy config to s3://#{deploy_bucket}/#{s3_key}"

        client = Aws::S3::Client.new(region: deploy_bucket_region)

        client.put_object(
          bucket: deploy_bucket,
          key: s3_key,
          body: context.server_deploy_opts.to_json,
          acl: "private"
        )
      end

      private

      def deploy_bucket
        Shipitron.config.deploy_bucket
      end

      def deploy_bucket_region
        Shipitron.config.deploy_bucket_region
      end
    end
  end
end
