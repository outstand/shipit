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

        build_cache.open('rb') do |local_file|
          bucket.files.create(
            key: "#{application}.build-cache.archive",
            body: local_file
          )
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

      def bucket
        @bucket ||= FetchBucket.call!(name: s3_cache_bucket).bucket
      end
    end
  end
end
