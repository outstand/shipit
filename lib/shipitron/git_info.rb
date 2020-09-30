require 'shipitron'

module Shipitron
  class GitInfo < Hashie::Dash
    property :sha
    property :short_sha
    property :email
    property :name
    property :summary
    property :timestamp
    property :branch

    def one_liner
      "#{name} (#{short_sha}): #{message}"
    end

    def self.from_path(path:)
      repo = Rugged::Repository.new("/home/shipitron/#{application}")
      ref = repo.head
      commit = repo.last_commit
      self.new(
        sha: commit.oid,
        short_sha: commit.oid[0, 12],
        email: commit.author.dig(:email),
        name: commit.author.dig(:name),
        summary: commit.summary,
        timestamp: commit.epoch_time,
        branch: ref.branch? ? ref.name.sub('refs/heads/', '') : ''
      )
    end
  end
end
