require 'shipitron'
require 'metaractor'
require 'shipitron/server/download_bundler_cache'
require 'shipitron/server/docker/run_build_script'
require 'shipitron/server/upload_bundler_cache'

module Shipitron
  module Server
    module Docker
      class BuildImage
        include Metaractor
        include Interactor::Organizer

        required :application
        required :image_name
        required :git_sha

        organize [
          DownloadBundlerCache,
          Docker::RunBuildScript,
          UploadBundlerCache
        ]
      end
    end
  end
end
