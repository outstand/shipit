#!/bin/sh

set -euo pipefail

if [ -n "$USE_BUNDLE_EXEC" ]; then
  BINARY="bundle exec shipitron"
else
  BINARY=shipitron
fi

# ${BINARY} help "$1"

if ls /usr/local/bundle/bin | grep -q "\b$1\b"; then
  set -- su-exec shipitron bundle exec "$@"

elif ${BINARY} help "$1" 2>&1 | grep -q "shipitron $1"; then
  set -- su-exec shipitron ${BINARY} "$@"
fi

exec "$@"
