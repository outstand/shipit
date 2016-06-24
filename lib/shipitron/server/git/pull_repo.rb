require 'shipitron'
require 'shipitron/server/git/configure'
require 'shipitron/server/git/download_cache'
require 'shipitron/server/git/update_cache'
require 'shipitron/server/git/upload_cache'
require 'shipitron/server/git/clone_local_copy'

module Shipitron
  module Server
    module Git
      class PullRepo
        include Metaractor
        include Interactor::Organizer

        required :application
        required :repository_url
        required :s3_cache_bucket

        organize [
          Configure,
          DownloadCache,
          UpdateCache,
          UploadCache,
          CloneLocalCopy
        ]
      end
    end
  end
end
