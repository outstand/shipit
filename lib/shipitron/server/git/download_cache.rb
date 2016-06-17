require 'shipitron'
require 'metaractor'
require 'shipitron/fetch_bucket'
require 'archive/tar/minitar'

module Shipitron
  module Server
    module Git
      class DownloadCache
        include Metaractor

        required :application
        required :s3_cache_bucket

        def call
          Logger.info "Downloading git cache from bucket #{s3_cache_bucket}"

          s3_file = bucket.files.get("#{application}.git.tar.gz")
          if s3_file.nil?
            Logger.warn 'Git cache not found.'
            return
          end

          Pathname.new("/tmp/#{application}.git.tar.gz").open('wb') do |local_file|
            local_file.write(s3_file.body)
          end

          extract_tarball(filename: "/tmp/#{application}.git.tar.gz", directory: '/home/shipitron')

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

        def extract_tarball(filename:, directory:)
          Pathname.new(filename).open('rb') do |tarball|
            Zlib::GzipReader.wrap(tarball) do |gz|
              Archive::Tar::Minitar.unpack(gz, directory)
            end
          end
        end

      end
    end
  end
end
