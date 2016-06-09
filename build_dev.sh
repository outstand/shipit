#!/bin/bash
set -e -x

bundler_data_container=''
tar_container=''

function cleanup {
  if [ -n "$bundler_data_container" ]; then
    docker stop bundler-data
    docker rm -f bundler-data
  fi

  if [ -n "$tar_container" ]; then
    docker rm -f ${tar_container}
  fi

  rm -f tmp/cidfile
}

trap cleanup EXIT

build_args=''
mkdir -p tmp

if [ -f $(pwd)/tmp/bundler-data.tar.gz ]; then
  docker run --name bundler-data -v $(pwd)/tmp/bundler-data.tar.gz:/usr/share/nginx/html/bundler-data.tar.gz:ro -d nginx:stable-alpine
  bundler_data_container=bundler-data
  build_args="--build-arg bundler_data_host=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bundler-data)"
fi

docker build -t outstand/shipitron:dev ${build_args} .

docker run -t --cidfile=tmp/cidfile -w /usr/local/bundle outstand/shipitron:dev tar -zcf /tmp/bundler-data.tar.gz .
tar_container=$(cat tmp/cidfile)
docker cp ${tar_container}:/tmp/bundler-data.tar.gz tmp/bundler-data.tar.gz
