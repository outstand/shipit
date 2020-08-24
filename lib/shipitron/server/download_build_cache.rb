require 'shipitron'
require 'shipitron/fetch_bucket'

module Shipitron
  module Server
    class DownloadBuildCache
      include Metaractor

      required :application
      required :s3_cache_bucket
      required :build_cache_location
      required :region

      def call
        Logger.info "Downloading build cache from bucket #{s3_cache_bucket}"

        s3_file = bucket.files.head("#{application}.build-cache.archive")
        if s3_file.nil?
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

      def bucket
        @bucket ||= FetchBucket.call!(name: s3_cache_bucket).bucket
      end
    end
  end
end
