#!/bin/sh

set -euo pipefail

su-exec ${FIXUID:?Missing FIXUID var}:${FIXGID:?Missing FIXGID var} fixuid

chown_dir() {
  dir=$1
  if [[ -d ${dir} ]] && [[ "$(stat -c %u:%g ${dir})" != "${FIXUID}:${FIXGID}" ]]; then
    echo chown $dir
    chown shipitron:shipitron $dir
  fi
}

chown_dir /home/shipitron
chown_dir /usr/local/bundle

if [ "$1" = 'bundle' ]; then
  set -- su-exec shipitron "$@"
  exec "$@"
fi

if [ -n "$USE_BUNDLE_EXEC" ]; then
  BINARY="bundle exec shipitron"
else
  BINARY=shipitron
fi

if [ "$(ls -A /usr/local/bundle/bin)" = '' ]; then
  echo 'command not in path and bundler not initialized'
  echo 'running bundle install'
  su-exec shipitron bundle install
fi

if ${BINARY} help "$1" 2>&1 | grep -q "shipitron $1"; then
  set -- su-exec shipitron ${BINARY} "$@"

  if [ -n "${FOG_LOCAL:-}" ]; then
    chown -R shipitron:shipitron /fog
  fi

  su-exec shipitron bash -c 'bundle check || bundle install'
fi

exec "$@"
