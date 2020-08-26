require 'shipitron/find_docker_volume_name'

describe Shipitron::FindDockerVolumeName do
  let(:ecs_container_metadata_uri_v4) { 'http://ecs_container_metadata_uri_v4' }
  let(:task_metadata_response) do
    '{"Cluster":"us-east-1-prod-blue","TaskARN":"arn:aws:ecs:us-east-1:123456:task/us-east-1-prod-blue/7c4316a685e34f59b581a6b504d5bdc1","Family":"shipitron-dev","Revision":"5","DesiredStatus":"RUNNING","KnownStatus":"RUNNING","PullStartedAt":"2020-08-26T15:31:45.969406698Z","PullStoppedAt":"2020-08-26T15:31:59.96520262Z","AvailabilityZone":"us-east-1e","Containers":[{"DockerId":"da420b5f3376df5deb6b00ced29a5fe3a2c220009edb7c7517eca4f0ef572e7b","Name":"shipitron","DockerName":"ecs-shipitron-dev-5-shipitron-aab6b098c9ceffcc9901","Image":"outstand/shipitron:dev","ImageID":"sha256:65b680a291d0e1f7fddb0dcee4d39eeeea81ac5073317b082f24b184e39bb983","Labels":{"com.amazonaws.ecs.cluster":"us-east-1-prod-blue","com.amazonaws.ecs.container-name":"shipitron","com.amazonaws.ecs.task-arn":"arn:aws:ecs:us-east-1:123456:task/us-east-1-prod-blue/7c4316a685e34f59b581a6b504d5bdc1","com.amazonaws.ecs.task-definition-family":"shipitron-dev","com.amazonaws.ecs.task-definition-version":"5"},"DesiredStatus":"RUNNING","KnownStatus":"RUNNING","Limits":{"CPU":768,"Memory":0},"CreatedAt":"2020-08-26T15:32:00.000942732Z","StartedAt":"2020-08-26T15:32:03.726132767Z","Type":"NORMAL","Volumes":[{"Source":"/bin/docker","Destination":"/bin/docker"},{"Source":"/var/run/docker.sock","Destination":"/var/run/docker.sock"},{"DockerName":"ecs-shipitron-dev-5-shipitron-home-dcd984d1a5b3a8a46300","Source":"/var/lib/docker/volumes/ecs-shipitron-dev-5-shipitron-home-dcd984d1a5b3a8a46300/_data","Destination":"/home/shipitron"},{"Source":"/var/lib/ecs/data/metadata/us-east-1-prod-blue/7c4316a685e34f59b581a6b504d5bdc1/shipitron","Destination":"/opt/ecs/metadata/8adb6682-e7a9-41c5-8598-e4ee9085505e"}],"Networks":[{"NetworkMode":"bridge","IPv4Addresses":["172.17.0.4"]}]}]}'
  end

  before do
    ENV['ECS_CONTAINER_METADATA_URI_V4'] = ecs_container_metadata_uri_v4
    Excon.defaults[:mock] = true
    Excon.stub(
      {
        method: :get,
        url: "#{ecs_container_metadata_uri_v4}/task"
      },
      {
        body: task_metadata_response,
        status: 200
      }
    )
  end

  it 'finds the full docker volume name' do
    result = Shipitron::FindDockerVolumeName.call(
      container_name: 'shipitron',
      volume_search: /shipitron-home/
    )

    expect(result).to be_success
    expect(result.volume_name).to eq 'ecs-shipitron-dev-5-shipitron-home-dcd984d1a5b3a8a46300'
  end
end
