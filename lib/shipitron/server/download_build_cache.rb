require "shipitron"
require "shipitron/s3_client"
require "shipitron/s3_copy"

module Shipitron
  module Server
    class DownloadBuildCache
      include Metaractor
      include S3Client

      required :application
      required :s3_cache_bucket
      required :build_cache_location
      required :region

      def call
        Logger.info "Downloading build cache from bucket #{s3_cache_bucket}"

        begin
          s3_client.head_object(
            bucket: s3_cache_bucket,
            key: "#{application}.build-cache.archive"
          )
        rescue Aws::S3::Errors::NoSuchKey
          Logger.warn 'Build cache not found.'
          return
        end

        build_cache = Pathname.new("/home/shipitron/#{application}/#{build_cache_location}")
        build_cache.parent.mkpath

        result = S3Copy.call(
          source: "s3://#{s3_cache_bucket}/#{application}.build-cache.archive",
          destination: build_cache.to_s,
          region: context.region
        )
        if result.failure?
          fail_with_error!(message: 'Failed to download build cache!')
        end

        Logger.info 'Download complete.'
      end

      private
      def application
        context.application
      end

      def s3_cache_bucket
        context.s3_cache_bucket
      end

      def build_cache_location
        context.build_cache_location
      end
    end
  end
end
