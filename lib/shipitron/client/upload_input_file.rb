require 'shipitron'
require 'shipitron/fetch_bucket'

module Shipitron
  module Client
    class UploadInputFile
      include Metaractor

      required :deployment_config

      def call
        context.input_file_name = "#{SecureRandom.uuid}.yml"
        Logger.info "Uploading input file #{input_file_name} to bucket #{deployment_config.s3_bucket}"

        Logger.debug { "input file body: #{deployment_config.to_yaml}" }
        bucket.files.create(
          key: "input/#{input_file_name}",
          body: deployment_config.to_yaml
        )

        Logger.info 'Upload complete.'
      end

      private
      def deployment_config
        context.deployment_config
      end

      def input_file_name
        context.input_file_name
      end

      def bucket
        @bucket ||= FetchBucket.call!(name: deployment_config.s3_bucket).bucket
      end
    end
  end
end
