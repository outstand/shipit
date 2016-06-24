require 'shipitron'
require 'shellwords'

module Shipitron
  module Server
    module Git
      class UpdateCache
        include Metaractor

        required :application
        required :repository_url
        required :s3_cache_bucket

        def call
          if !Pathname.new('/home/shipitron/git-cache/objects').directory?
            Logger.info 'Cloning the git repository'
            FileUtils.cd('/home/shipitron') do
              `git clone --bare #{Shellwords.escape repository_url} git-cache`
            end
          else
            Logger.info 'Fetching new git commits'
            FileUtils.cd('/home/shipitron/git-cache') do
              `git fetch #{Shellwords.escape repository_url} master:master`
            end
          end
        end

        private
        def application
          context.application
        end

        def repository_url
          context.repository_url
        end

        def s3_cache_bucket
          context.s3_cache_bucket
        end
      end
    end
  end
end
