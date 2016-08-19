require 'shipitron'
require 'shipitron/fetch_bucket'

module Shipitron
  module Server
    class UploadBuildCache
      include Metaractor

      required :application
      required :s3_cache_bucket

      def call
        Logger.info "Uploading bundler cache to bucket #{s3_cache_bucket}"

        bundler_cache = Pathname.new("/home/shipitron/#{application}/tmp/bundler-cache.tar.gz")
        unless bundler_cache.exist?
          Logger.warn 'Bundler cache not found.'
          return
        end

        bundler_cache.open('rb') do |local_file|
          bucket.files.create(
            key: "#{application}.bundler-cache.tar.gz",
            body: local_file.read
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

      def bucket
        @bucket ||= FetchBucket.call!(name: s3_cache_bucket).bucket
      end
    end
  end
end
