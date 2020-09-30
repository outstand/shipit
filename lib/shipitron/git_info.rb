require 'shipitron'
require 'rugged'

module Shipitron
  class GitInfo < Hashie::Dash
    property :sha
    property :short_sha
    property :email
    property :name
    property :summary
    property :timestamp
    property :branch
    property :tag

    def one_liner
      "#{name} (#{short_sha}): #{summary}"
    end

    def self.from_path(path:)
      repo = Rugged::Repository.new(path)
      commit = repo.last_commit
      self.new(
        sha: commit.oid,
        short_sha: commit.oid[0, 12],
        email: commit.author.dig(:email),
        name: commit.author.dig(:name),
        summary: commit.summary,
        timestamp: commit.epoch_time.to_s,
        branch: branch_name(repo: repo),
        tag: tag_name(repo: repo)
      )
    end

    def self.branch_name(repo:)
      ref = repo.head
      ref.branch? ? ref.name.sub('refs/heads/', '') : nil
    end

    def self.tag_name(repo:)
      ref = repo.head
      tags = repo.tags

      tags.each do |tag|
        target_id =
          if tag.annotated?
            tag.annotation.target_id
          else
            tag.target.oid
          end

        return tag.name if ref.target_id == target_id
      end

      nil
    end
  end
end
