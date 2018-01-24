require 'shipitron/client/fetch_clusters'

RSpec.describe Shipitron::Client::FetchClusters do
  let(:cluster_discovery) { double(:cluster_discovery) }
  let(:action) do
    Shipitron::Client::FetchClusters.new(
      cluster_discovery: cluster_discovery
    )
  end
  let(:result) { action.context }

  before do
    allow(action).to receive(:dns_resources) { resources }
  end

  context 'with multiple clusters' do
    let(:resources) {
      [
        Resolv::DNS::Resource::IN::SRV.new(10, 0, 0, 'blue.us-east-1'),
        Resolv::DNS::Resource::IN::SRV.new(10, 10, 0, 'green.us-east-1'),
        Resolv::DNS::Resource::IN::SRV.new(10, 20, 0, 'red.us-east-1')
      ]
    }

    it 'returns red,green,blue' do
      action.run
      expect(result.clusters).to eq([
        Shipitron::Smash.new(name: 'red', region: 'us-east-1'),
        Shipitron::Smash.new(name: 'green', region: 'us-east-1'),
        Shipitron::Smash.new(name: 'blue', region: 'us-east-1')
      ])
    end
  end

  context 'with multiple regions' do
    let(:resources) {
      [
        Resolv::DNS::Resource::IN::SRV.new(10, 0, 0, 'blue.us-east-1'),
        Resolv::DNS::Resource::IN::SRV.new(10, 10, 0, 'green.us-east-1'),
        Resolv::DNS::Resource::IN::SRV.new(10, 20, 0, 'red.us-east-1'),
        Resolv::DNS::Resource::IN::SRV.new(20, 0, 0, 'blue.us-west-1'),
        Resolv::DNS::Resource::IN::SRV.new(20, 10, 0, 'green.us-west-1'),
        Resolv::DNS::Resource::IN::SRV.new(20, 20, 0, 'red.us-west-1')
      ]
    }

    it 'returns red,green,blue with east first' do
      action.run
      expect(result.clusters).to eq([
        Shipitron::Smash.new(name: 'red', region: 'us-east-1'),
        Shipitron::Smash.new(name: 'green', region: 'us-east-1'),
        Shipitron::Smash.new(name: 'blue', region: 'us-east-1'),
        Shipitron::Smash.new(name: 'red', region: 'us-west-1'),
        Shipitron::Smash.new(name: 'green', region: 'us-west-1'),
        Shipitron::Smash.new(name: 'blue', region: 'us-west-1')
      ])
    end

  end
end
