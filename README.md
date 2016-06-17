# shipitron
A deployment tool for use with Docker and ECS

## Usage

- Create shipitron.yml file
- `docker run -it --rm -v shipitron.yml:/shipitron/config/shipitron.yml outstand/shipitron:<version> deploy <app>`

## Development

- `docker volume create --name shipitron_fog`
- `./build_dev.sh`
- `docker run -it --rm -v $(pwd):/shipitron -v shipitron_fog:/fog -e FOG_LOCAL=true outstand/shipitron:dev rspec spec` to run specs
- `docker run -it --rm -v $(pwd):/shipitron outstand/shipitron:dev deploy <app>` to run client side
- `docker run -it --rm -v $(pwd):/shipitron -v shipitron_fog:/fog -e FOG_LOCAL=true -e CONSUL_HOST=<consul host> outstand/shipitron:dev server_deploy <app>` to run server side
