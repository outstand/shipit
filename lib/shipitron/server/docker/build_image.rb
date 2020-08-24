require 'shipitron'
require 'shipitron/server/download_build_cache'
require 'shipitron/server/docker/run_build_script'
require 'shipitron/server/upload_build_cache'

module Shipitron
  module Server
    module Docker
      class BuildImage
        include Metaractor
        include Interactor::Organizer

        required :application
        required :docker_image
        required :git_sha
        required :named_tag
        required :region
        optional :registry

        organize [
          DownloadBuildCache,
          Docker::RunBuildScript,
          UploadBuildCache
        ]
      end
    end
  end
end
