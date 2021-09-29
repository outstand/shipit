require 'shipitron'
require 'shipitron/server/git/configure'
require 'shipitron/server/git/clone'

module Shipitron
  module Server
    module Git
      class PullRepo
        include Metaractor
        include Interactor::Organizer

        required :application
        required :repository_url
        optional :repository_branch

        organize [
          Configure,
          Clone
        ]
      end
    end
  end
end
