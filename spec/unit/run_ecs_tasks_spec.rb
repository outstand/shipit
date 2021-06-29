require 'shipitron/client/run_ecs_tasks'
describe Shipitron::Client::RunEcsTasks do
  let(:application) { 'skynet' }
  let(:clusters) do
    [
      Shipitron::Smash.new(name: 'blue', region: 'us-east-1'),
      Shipitron::Smash.new(name: 'green', region: 'us-west-1')
    ]
  end
  let(:shipitron_task) { 'shipitron' }
  let(:repository_url) { 'git@github.com:outstand/dummy-app' }
  let(:s3_cache_bucket) { 'outstand-shipitron' }
  let(:build_cache_location) { 'tmp/build-cache.tar.gz' }
  let(:image_name) { 'outstand/dummy-app' }
  let(:named_tag) { 'latest' }
  let(:ecs_task_defs) { ['dummy-app'] }
  let(:ecs_services) { ['dummy-app'] }
  let(:action) do
    Shipitron::Client::RunEcsTasks.new(
      application: application,
      clusters: clusters,
      shipitron_task: shipitron_task,
      repository_url: repository_url,
      s3_cache_bucket: s3_cache_bucket,
      build_cache_location: build_cache_location,
      image_name: image_name,
      named_tag: named_tag,
      ecs_task_defs: ecs_task_defs,
      ecs_services: ecs_services
    )
  end
  let(:result) { action.context }
  let(:east_ecs_client) { double(:east_ecs_client) }
  let(:west_ecs_client) { double(:west_ecs_client) }
  let(:deploy_id) { "TOTALLY-A-UUID" }
  let(:response) do
    Shipitron::Smash.new(failures: [])
  end

  before do
    allow(action).to receive(:ecs_client).with(region: 'us-east-1').and_return east_ecs_client
    allow(action).to receive(:ecs_client).with(region: 'us-west-1').and_return west_ecs_client
    allow(east_ecs_client).to receive(:run_task).and_return(response)
    allow(west_ecs_client).to receive(:run_task).and_return(response)
    allow(action).to receive(:deploy_id) { deploy_id }
    allow(action).to receive(:generate_deploy!)
  end

  it 'runs the task for the blue cluster' do
    action.run!
    expect(east_ecs_client).to have_received(:run_task).with(
      hash_including(
        cluster: 'blue',
        task_definition: shipitron_task,
        overrides: {
          container_overrides: [
            {
              name: 'shipitron',
              command: [
                'server_deploy',
                '--deploy-id', deploy_id
              ]
            }
          ]
        },
        count: 1,
        started_by: Shipitron::Client.started_by
      )
    )
    expect(action).to have_received(:generate_deploy!)
  end

  it 'does not run the task for the green cluster' do
    action.run!
    expect(west_ecs_client).to_not have_received(:run_task)
  end

  context 'when there is a ServiceError' do
    let(:request_context) { double(:request_context) }
    let(:message) { 'oops' }
    before do
      allow(east_ecs_client).to receive(:run_task).and_raise(
        Aws::ECS::Errors::ServiceError.new(request_context, message)
      )
    end

    it 'fails' do
      action.run
      expect(result).to be_a_failure
      expect(result.errors).to_not be_empty
    end
  end

  context 'when there is a response failure' do
    let(:response) do
      Shipitron::Smash.new(failures: [
        {arn: 'arn', reason: 'oops'}
      ])
    end

    it 'fails' do
      action.run
      expect(result).to be_a_failure
      expect(result.errors).to_not be_empty
    end

  end
end
