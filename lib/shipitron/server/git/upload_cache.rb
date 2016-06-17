require 'shipitron'
require 'metaractor'
require 'shipitron/fetch_bucket'
require 'find'
require 'archive/tar/minitar'

module Shipitron
  module Server
    module Git
      class UploadCache
        include Metaractor

        required :application
        required :s3_cache_bucket

        def call
          Logger.info "Uploading git cache to bucket #{s3_cache_bucket}"
          create_tarball(filename: "/tmp/#{application}.git.tar.gz", directory: '/home/shipitron/git-cache')

          Pathname.new("/tmp/#{application}.git.tar.gz").open('rb') do |local_file|
            bucket.files.create(
              key: "#{application}.git.tar.gz",
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

        def create_tarball(filename:, directory:)
          base_dir = Pathname.new(directory).parent
          Logger.debug 'Creating tarball'
          FileUtils.cd(base_dir) do
            Pathname.new(filename).open('wb') do |tarball|
              Zlib::GzipWriter.wrap(tarball) do |gz|
                Archive::Tar::Minitar::Output.open(gz) do |tar|
                  Find.find(directory) do |path|
                    pn = Pathname.new(path)
                    name = pn.relative_path_from(base_dir)
                    Logger.debug(name)
                    Archive::Tar::Minitar.pack_file(name.to_s, tar)
                  end
                end
              end
            end
          end
        end

        def bucket
          @bucket ||= FetchBucket.call!(name: s3_cache_bucket).bucket
        end
      end
    end
  end
end
