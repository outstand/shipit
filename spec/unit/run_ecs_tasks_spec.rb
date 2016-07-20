require 'shipitron/client/run_ecs_tasks'
describe Shipitron::Client::RunEcsTasks do
  let(:application) { 'skynet' }
  let(:clusters) do
    [
      Smash.new(name: 'blue', region: 'us-east-1'),
      Smash.new(name: 'green', region: 'us-west-1')
    ]
  end
  let(:ecs_task) { 'shipitron' }
  let(:action) do
    Shipitron::Client::RunEcsTasks.new(
      application: application,
      clusters: clusters,
      ecs_task: ecs_task
    )
  end
  let(:result) { action.context }
  let(:east_ecs_client) { action.ecs_client(region: 'us-east-1') }
  let(:west_ecs_client) { action.ecs_client(region: 'us-west-1') }
  let(:response) do
    Smash.new(failures: [])
  end

  before do
    allow(east_ecs_client).to receive(:run_task).and_return(response)
    allow(west_ecs_client).to receive(:run_task).and_return(response)
  end

  it 'runs the task for the blue cluster' do
    action.run!
    expect(east_ecs_client).to have_received(:run_task).with(
      hash_including(
        cluster: 'blue',
        task_definition: ecs_task,
        count: 1,
        started_by: 'shipitron'
      )
    )
  end

  it 'runs the task for the green cluster' do
    action.run!
    expect(west_ecs_client).to have_received(:run_task).with(
      hash_including(
        cluster: 'green',
        task_definition: ecs_task,
        count: 1,
        started_by: 'shipitron'
      )
    )
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
      Smash.new(failures: [
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
