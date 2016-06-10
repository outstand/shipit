#!/bin/bash
set -e -x

build_image=outstand/shipitron:dev
dockerfile=Dockerfile
bundler_data_dir=tmp

bundler_data_container=''
tar_container=''

function cleanup {
  if [ -n "$bundler_data_container" ]; then
    docker stop bundler-data
    docker rm -fv bundler-data
  fi

  if [ -n "$tar_container" ]; then
    docker rm -fv ${tar_container}
  fi

  rm -f ${bundler_data_dir}/cidfile
}

trap cleanup EXIT

build_args=''
mkdir -p ${bundler_data_dir}

if [ -f $(pwd)/${bundler_data_dir}/bundler-data.tar.gz ]; then
  docker run --name bundler-data -v $(pwd)/${bundler_data_dir}/bundler-data.tar.gz:/usr/share/nginx/html/bundler-data.tar.gz:ro -d nginx:stable-alpine
  bundler_data_container=bundler-data
  build_args="--build-arg bundler_data_host=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bundler-data)"
fi

docker build -t ${build_image} -f ${dockerfile} ${build_args} .

docker run -t --cidfile=${bundler_data_dir}/cidfile -w /usr/local/bundle ${build_image} tar -zcf /tmp/bundler-data.tar.gz .
tar_container=$(cat ${bundler_data_dir}/cidfile)
docker cp ${tar_container}:/tmp/bundler-data.tar.gz ${bundler_data_dir}/bundler-data.tar.gz
