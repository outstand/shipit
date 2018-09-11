require 'shipitron'
require 'shipitron/fetch_bucket'

module Shipitron
  module Server
    class DownloadBuildCache
      include Metaractor

      required :application
      required :s3_cache_bucket
      required :build_cache_location

      def call
        Logger.info "Downloading build cache from bucket #{s3_cache_bucket}"

        s3_file = bucket.files.get("#{application}.build-cache.archive")
        if s3_file.nil?
          Logger.warn 'Build cache not found.'
          return
        end

        build_cache = Pathname.new("/home/shipitron/#{application}/#{build_cache_location}")
        build_cache.parent.mkpath
        build_cache.open('wb') do |local_file|
          local_file.write(s3_file.body)
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
