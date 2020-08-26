#!/bin/sh
set -e

chown_dir() {
  dir=$1
  if [ "$(stat -c %u ${dir})" = '0' ]; then
    chown -R shipitron:shipitron $dir
  fi
}

chown_dir /home/shipitron

if [ -n "$USE_BUNDLE_EXEC" ]; then
  BINARY="bundle exec shipitron"
else
  BINARY=shipitron
fi

if ${BINARY} help "$1" 2>&1 | grep -q "shipitron $1"; then
  set -- su-exec shipitron ${BINARY} "$@"

  if [ -n "$FOG_LOCAL" ]; then
    chown -R shipitron:shipitron /fog
  fi
fi

exec "$@"
