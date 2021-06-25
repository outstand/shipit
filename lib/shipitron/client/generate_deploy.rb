require 'shipitron'
require 'shipitron/client'
require 'shipitron/fetch_bucket'
require 'securerandom'
require 'aws-sdk-s3'

module Shipitron
  module Client
    class GenerateDeploy
      include Metaractor

      BUCKET_PREFIX = "deploys/"

      required :s3_cache_bucket
      required :server_deploy_args
      required :deploy_id

      def call
        s3_key = "#{BUCKET_PREFIX}#{context.deploy_id}"
        Logger.info "Uploading deploy config to s3://#{context.s3_cache_bucket}#{s3_key}"

        client = Aws::S3::Client.new(region: context.region)

        # TODO: Do something clever with aws-sdk-s3

        # bucket.files.create(
        #   key: s3_key,
        #   body: context.server_deploy_args.to_json
        # )
      end
    end
  end
end
