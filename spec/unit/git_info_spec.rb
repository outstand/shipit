require 'shipitron/git_info'
require 'pathname'

RSpec.describe Shipitron::GitInfo do
  let(:fixtures_dir) { '/shipitron/spec/fixtures' }
  let(:repo_dir) { '/shipitron/spec/fixtures/test_repo' }

  before do
    Dir.chdir(fixtures_dir) do
      unless Pathname.new(repo_dir).directory?
        `tar -zxf test_repo.tgz`
      end
    end
  end

  describe '.from_path' do
    it 'builds a valid git info' do
      git_info = Shipitron::GitInfo.from_path(path: repo_dir)

      expect(git_info.sha).to eq '3c4252d2ce682afe992d1e1cd21c5302de1add2d'
      expect(git_info.short_sha).to eq '3c4252d2ce68'
      expect(git_info.email).to eq 'ryan@ryanschlesinger.com'
      expect(git_info.name).to eq 'Ryan Schlesinger'
      expect(git_info.summary).to eq 'Add bar'
      expect(git_info.timestamp).to eq '1601476924'
      expect(git_info.branch).to eq 'main'
      expect(git_info.tag).to eq 'bar-tag'

      expect(git_info.one_liner).to eq 'Ryan Schlesinger (3c4252d2ce68): Add bar'
    end
  end
end
