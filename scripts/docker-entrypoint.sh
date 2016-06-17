#!/bin/dumb-init /bin/sh
set -e

if [ -n "$USE_BUNDLE_EXEC" ]; then
  BINARY="bundle exec shipitron"
else
  BINARY=shipitron
fi

if ${BINARY} help "$1" 2>&1 | grep -q "shipitron $1"; then
  set -- gosu shipitron ${BINARY} "$@"

  if [ -n "$FOG_LOCAL" ]; then
    chown -R shipitron:shipitron /fog
  fi
fi

exec "$@"
