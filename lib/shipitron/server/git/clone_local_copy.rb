require 'shipitron'
require 'shellwords'

module Shipitron
  module Server
    module Git
      class CloneLocalCopy
        include Metaractor

        required :application
        required :repository_url
        optional :repository_branch

        before do
          context.repository_branch ||= 'master'
        end

        def call
          Logger.info "Using this branch: #{repository_branch}"
          FileUtils.cd('/home/shipitron') do
            `git clone git-cache #{Shellwords.escape application} --recursive --branch #{Shellwords.escape repository_branch}`
          end

          Logger.info 'Using this git commit:'
          FileUtils.cd("/home/shipitron/#{application}") do
            context.git_sha = `git rev-parse --short=12 HEAD`.chomp
            Logger.info `git --no-pager log --format='%aN (%h): %s' -n 1`.chomp
          end
        end

        private
        def application
          context.application
        end

        def repository_url
          context.repository_url
        end

        def repository_branch
          context.repository_branch
        end
      end
    end
  end
end
