require 'shipitron/client/ensure_deploy_not_running'
describe Shipitron::Client::EnsureDeployNotRunning do
  let(:clusters) do
    [
      Shipitron::Smash.new(name: 'blue', region: 'us-east-1'),
      Shipitron::Smash.new(name: 'green', region: 'us-west-1')
    ]
  end
  let(:action) do
    Shipitron::Client::EnsureDeployNotRunning.new(
      clusters: clusters
    )
  end
  let(:result) { action.context }

  let(:blue_pending_response) { Shipitron::Smash.new(task_arns: []) }
  let(:blue_running_response) { Shipitron::Smash.new(task_arns: []) }
  let(:green_pending_response) { Shipitron::Smash.new(task_arns: []) }
  let(:green_running_response) { Shipitron::Smash.new(task_arns: []) }
  let(:east_ecs_client) { double(:east_ecs_client) }
  let(:west_ecs_client) { double(:west_ecs_client) }

  before do
    allow(action).to receive(:ecs_client).with(region: 'us-east-1').and_return east_ecs_client
    allow(action).to receive(:ecs_client).with(region: 'us-west-1').and_return west_ecs_client

    allow(east_ecs_client).to receive(:list_tasks).with(
      hash_including(desired_status: 'PENDING')
    ).and_return(blue_pending_response)
    allow(east_ecs_client).to receive(:list_tasks).with(
      hash_including(desired_status: 'RUNNING')
    ).and_return(blue_running_response)
    allow(west_ecs_client).to receive(:list_tasks).with(
      hash_including(desired_status: 'PENDING')
    ).and_return(green_pending_response)
    allow(west_ecs_client).to receive(:list_tasks).with(
      hash_including(desired_status: 'RUNNING')
    ).and_return(green_running_response)
  end

  context 'with no tasks running' do
    it 'succeeds' do
      action.run
      expect(result).to be_a_success
    end
  end

  context 'with a blue pending task' do
    let(:blue_pending_response) { Shipitron::Smash.new(task_arns: [:a_deploy]) }

    it 'fails' do
      action.run
      expect(result).to be_a_failure
      expect(result.errors).to include('Deploy is already running.')
    end
  end

  context 'with a green running task' do
    let(:green_running_response) { Shipitron::Smash.new(task_arns: [:a_deploy]) }

    it 'fails' do
      action.run
      expect(result).to be_a_failure
      expect(result.errors).to include('Deploy is already running.')
    end
  end

  context 'when the cluster cannot be found' do
    let(:request_context) { double(:request_context) }
    let(:message) { 'oops' }
    before do
      allow(east_ecs_client).to receive(:list_tasks).and_raise(
        Aws::ECS::Errors::ClusterNotFoundException.new(request_context, message)
      )
    end

    it 'fails' do
      action.run
      expect(result).to be_a_failure
      expect(result.errors).to include("Cluster 'blue' not found in region us-east-1.")
    end
  end
end
