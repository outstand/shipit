require 'shipitron'
require 'metaractor'
require 'shipitron/fetch_bucket'

module Shipitron
  module Server
    class DownloadBundlerCache
      include Metaractor

      required :application
      required :s3_cache_bucket

      def call
        Logger.info "Downloading bundler cache from bucket #{s3_cache_bucket}"

        s3_file = bucket.files.get("#{application}.bundler-cache.tar.gz")
        if s3_file.nil?
          Logger.warn 'Bundler cache not found.'
          return
        end

        bundler_cache = Pathname.new("/home/shipitron/#{application}/tmp/bundler-cache.tar.gz")
        bundler_cache.parent.mkpath
        bundler_cache.open('wb') do |local_file|
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

      def bucket
        @bucket ||= FetchBucket.call!(name: s3_cache_bucket).bucket
      end
    end
  end
end
