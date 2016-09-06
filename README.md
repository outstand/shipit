# shipitron
A deployment tool for use with Docker and ECS

## Usage

Example config file:
```yaml
applications:
  dummy-app:
    repository: git@github.com:outstand/dummy-app
    cache_bucket: bucket
    image_name: outstand/dummy-app
    build_script: shipitron/build.sh
    post_builds:
      - ecs_task: dummy-app
        container_name: dummy-app
        command: echo postbuild
    ecs_clusters:
      - name: us-east-1-prod-blue
        region: us-east-1
      - name: us-east-1-prod-green
        region: us-east-1
    shipitron_task: shipitron
    ecs_task_defs:
      - dummy-app
    ecs_services:
      - dummy-app
```

- Create shipitron.yml file
- Add needed ssh known hosts to `shipitron/<app name>/git_host_key` in consul k/v
- Add git ssh deploy key to `shipitron/<app name>/git_deploy_key` in consul k/v
- Add docker auth config (`~/.docker/config.json` after `docker login`) to `shipitron/<app name>/docker_auth` in consul k/v
- `docker run -it --rm -v shipitron.yml:/shipitron/config/shipitron.yml outstand/shipitron:<version> deploy <app>`

## Development

- `docker volume create --name shipitron_fog`
- `./build_dev.sh`
- `docker run -it --rm -v $(pwd):/shipitron -v shipitron_fog:/fog -e FOG_LOCAL=true outstand/shipitron:dev rspec spec` to run specs
- `docker run -it --rm -v $(pwd):/shipitron -v /path/to/app:/app outstand/shipitron:dev deploy <app>` to run client side
- `docker run -it --rm -v $(pwd):/shipitron -v /path/to/app:/app outstand/shipitron:dev deploy <app> --simulate` to get the arguments for `server_deploy` below
- `docker run -it --rm --dns 10.10.10.2 -v $(pwd):/shipitron -v /path/to/app:/app -v /bin/docker:/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -v shipitron_fog:/fog -e FOG_LOCAL=true -e CONSUL_HOST=consul outstand/shipitron:dev server_deploy --name dummy-app --repository git@github.com:outstand/dummy-app --bucket outstand-shipitron --image-name outstand/dummy-app --region us-east-1 --cluster-name us-east-1-prod-blue --ecs-task-defs dummy-app --ecs-services dummy-app --build-script shipitron/build.sh --post-builds 'ecs_task:dummy-app,container_name:dummy-app,command:echo postbuild' --ecs-task-def-templates LS0tCmZhbWlseTogZHVtbXktYXBwCmNvbnRhaW5lcl9kZWZpbml0aW9uczoKICAtIG5hbWU6IGR1bW15LWFwcAogICAgaW1hZ2U6IG91dHN0YW5kL2R1bW15LWFwcDp7e3RhZ319CiAgICBtZW1vcnk6IDEyOAogICAgZXNzZW50aWFsOiB0cnVlCiAgICBwb3J0X21hcHBpbmdzOgogICAgICAtIGNvbnRhaW5lcl9wb3J0OiA4MAogICAgZW52aXJvbm1lbnQ6CiAgICAgIC0gbmFtZTogU0VSVklDRV84MF9OQU1FCiAgICAgICAgdmFsdWU6IGR1bW15Cg== --ecs-service-templates LS0tCmNsdXN0ZXI6IHt7Y2x1c3Rlcn19CnNlcnZpY2VfbmFtZTogZHVtbXktYXBwCnRhc2tfZGVmaW5pdGlvbjogZHVtbXktYXBwe3tyZXZpc2lvbn19CmRlc2lyZWRfY291bnQ6IHt7Y291bnR9fQojcm9sZToge3tyb2xlfX0KZGVwbG95bWVudF9jb25maWd1cmF0aW9uOgogIG1heGltdW1fcGVyY2VudDogMjAwCiAgbWluaW11bV9oZWFsdGh5X3BlcmNlbnQ6IDUwCg== --debug` to run server side (dummy-app is an example)

To release a new version:
- Update the version number in `version.rb` and `Dockerfile.release` and commit the result.
- `./build_dev.sh`
- `docker run -it --rm -v ~/.gitconfig:/root/.gitconfig -v ~/.gitconfig.user:/root/.gitconfig.user -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v ~/.gem:/root/.gem -w /shipitron outstand/shipitron:dev rake release`
- `docker build -t outstand/shipitron:VERSION -f Dockerfile.release .`
- `docker push outstand/shipitron:VERSION`
