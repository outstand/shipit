require 'shipitron/server/fetch_deploy'

RSpec.describe Shipitron::Server::FetchDeploy do
  let(:deploy_bucket) { 'shipitron' }
  let(:deploy_bucket_region) { 'us-east-1' }
  let(:deploy_id) { "TOTALLY-A-UUID" }
  let(:deploy_options) do
    {
      name: "application"
    }
  end

  let(:action) do
    Shipitron::Server::FetchDeploy.new(
      deploy_bucket: deploy_bucket,
      deploy_bucket_region: deploy_bucket_region,
      deploy_id: deploy_id
    )
  end
  let(:result) { action.context }

  before do
    allow(action).to receive(:client_opts).and_return(
      {
        stub_responses: {
          get_object: { body: deploy_options.to_json }
        }
      }
    )
  end

  it 'downloads the deploy config from s3' do
    action.run!

    expect(result.deploy_options).to eq deploy_options
  end
end
