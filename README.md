# shipit
A deployment tool for use with Docker and ECS

## TODO
- [ ] user runs `docker run -it --rm outstand/shipit deploy production`
- [ ] shipit container calls `RunTask` to schedule the actual build
- [ ] ECS runs `docker run -t outstand/shipit-server deploy production`
- [ ] shipit container pulls git updates (pull cache from S3 in v2)
- [ ] shipit container calls `build-prod.sh` script to build production container
- [ ] `docker push`
- [ ] `RegisterTaskDefinition`
- [ ] `RunTask` (`rake db:migrate`) or `docker run`
- [ ] `UpdateService` (updates service to use new task definition)
