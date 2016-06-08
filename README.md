# shipitron
A deployment tool for use with Docker and ECS

## TODO
- [x] user runs `docker run -it --rm outstand/shipitron deploy production`
- [x] shipitron container calls `RunTask` to schedule the actual build
- [ ] ECS runs `docker run -t outstand/shipitron-server deploy production`
- [ ] shipit container pulls git updates (pull cache from S3 in v2)
- [ ] shipit container calls `build-prod.sh` script to build production container
- [ ] `docker push`
- [ ] `RegisterTaskDefinition`
- [ ] `RunTask` (`rake db:migrate`) or `docker run`
- [ ] `UpdateService` (updates service to use new task definition)

## Development

- `docker build -t outstand/shipitron:dev .`
- `docker run -it --rm -v $(pwd):/shipitron outstand/shipitron:dev deploy outstand`
