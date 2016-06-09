# shipitron
A deployment tool for use with Docker and ECS

## TODO
- [x] user runs `docker run -it --rm outstand/shipitron deploy <app>`
- [x] shipitron container calls `RunTask` to schedule the actual build
- [ ] ECS runs `docker run -t outstand/shipitron server_deploy <app>`
- [ ] shipit container pulls git updates (pull cache from S3 in v2)
- [ ] shipit container calls `build-prod.sh` script to build production container
- [ ] `docker push`
- [ ] `RegisterTaskDefinition`
- [ ] `RunTask` (`rake db:migrate`) or `docker run`
- [ ] `UpdateService` (updates service to use new task definition)

## Development

- `./build_dev.sh`
- `docker run -it --rm -v $(pwd):/shipitron outstand/shipitron:dev deploy <app>`
