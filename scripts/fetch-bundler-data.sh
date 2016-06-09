#!/bin/sh
set -x

if [ -z "$1" ]; then
  echo 'Missing argument: bundler data host'
  exit 0
fi

wget -T 2 -O /tmp/bundler-data.tar.gz http://${1}/bundler-data.tar.gz
if [ $? -ne 0 ]; then
  echo 'Unable to fetch bundler data.'
else
  cd /usr/local/bundle && \
    tar -zxf /tmp/bundler-data.tar.gz && \
    rm /tmp/bundler-data.tar.gz
fi
