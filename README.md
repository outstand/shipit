# shipitron
A deployment tool for use with Docker and ECS

## Development

- `./build_dev.sh`
- `docker run -it --rm -v $(pwd):/shipitron outstand/shipitron:dev deploy <app>`
- `docker run -it --rm -v $(pwd):/shipitron outstand/shipitron:dev rspec spec` to run specs
