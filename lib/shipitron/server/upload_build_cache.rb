require 'shipitron'
require 'shipitron/fetch_bucket'

module Shipitron
  module Server
    class UploadBuildCache
      include Metaractor

      required :application
      required :s3_cache_bucket
      required :build_cache_location

      def call
        Logger.info "Uploading build cache to bucket #{s3_cache_bucket}"

        build_cache = Pathname.new("/home/shipitron/#{application}/#{build_cache_location}")
        unless build_cache.exist?
          Logger.warn 'Build cache not found.'
          return
        end

        result = S3Copy.call(
          source: build_cache.to_s,
          destination: "s3://#{s3_cache_bucket}/#{application}.build-cache.archive"
        )
        if result.failure?
          Logger.warn 'Failed to upload build cache!'
        else
          Logger.info 'Upload complete.'
        end
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
