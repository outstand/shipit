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
    ecs_tasks:
      - dummy-app
    ecs_services:
      - dummy-app
```

- Create shipitron.yml file
- `docker run -it --rm -v shipitron.yml:/shipitron/config/shipitron.yml outstand/shipitron:<version> deploy <app>`

## Development

- `docker volume create --name shipitron_fog`
- `./build_dev.sh`
- `docker run -it --rm -v $(pwd):/shipitron -v shipitron_fog:/fog -e FOG_LOCAL=true outstand/shipitron:dev rspec spec` to run specs
- `docker run -it --rm -v $(pwd):/shipitron outstand/shipitron:dev deploy <app>` to run client side
- `docker run -it --rm -v $(pwd):/shipitron -v shipitron_fog:/fog -e FOG_LOCAL=true -e CONSUL_HOST=<consul host> outstand/shipitron:dev server_deploy <app>` to run server side
