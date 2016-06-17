require 'fog/aws'
require 'fog/local' if ENV['FOG_LOCAL']

module Shipitron
  class FetchBucket
    include Metaractor

    required :name

    def call
      if ENV['FOG_LOCAL']
        Logger.debug 'Using fog local storage'
        storage = Fog::Storage.new provider: 'Local', local_root: '/fog'
        context.bucket = storage.directories.create(key: name)
      else
        storage = Fog::Storage.new provider: 'AWS', use_iam_profile: true
        context.bucket = storage.directories.get(name)
      end
    end

    private
    def name
      context.name
    end
  end
end
