#!/bin/bash

set -euo pipefail

if [ "$1" = 'console' ]; then
  shift
  set -- bash "$@"
fi

echo "HELLO WORLD!"

exec "$@"
