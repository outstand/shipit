#!/bin/bash
set -e -x

build_image=outstand/shipitron:dev
dockerfile=Dockerfile
bundler_data_dir=cache

tar_container=''

function cleanup {
  if [ -n "$tar_container" ]; then
    docker rm -fv ${tar_container}
  fi

  rm -f ${bundler_data_dir}/cidfile
}

trap cleanup EXIT

build_args=''
mkdir -p ${bundler_data_dir}

docker build -t ${build_image} -f ${dockerfile} ${build_args} .

docker run -t --cidfile=${bundler_data_dir}/cidfile -w /usr/local/bundle ${build_image} tar -zcf /tmp/bundler-data.tar.gz .
tar_container=$(cat ${bundler_data_dir}/cidfile)
docker cp ${tar_container}:/tmp/bundler-data.tar.gz ${bundler_data_dir}/bundler-data.tar.gz
