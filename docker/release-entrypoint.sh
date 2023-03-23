#!/bin/bash

set -euo pipefail

if [ -n "${USE_BUNDLE_EXEC:-}" ]; then
  BINARY="bundle exec shipitron"
else
  BINARY=shipitron
fi

# su-exec shipitron ${BINARY} help "$1"

if [ "$1" = 'console' ]; then
  shift
  set -- su-exec shipitron bash "$@"
elif ls /usr/local/bundle/bin | grep -q "\b$1\b"; then
  set -- su-exec shipitron bundle exec "$@"

elif su-exec shipitron ${BINARY} help "$1" 2>&1 | grep -q "shipitron $1"; then
  set -- su-exec shipitron ${BINARY} "$@"
fi

exec "$@"
