#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
source functions

export EXPOSE_PORT="${1:-8888}"

function onExit() {
  docker-compose -f docker-compose.yml down
  cd "${ORIG_DIR}"
}
trap "onExit" EXIT

# Check docker is installed
if ! hash docker 2>/dev/null; then
  error "ERROR: docker must be installed - not found. Aborting..."
  exit 1
fi

# Run with docker-compose
if hash docker-compose 2>/dev/null; then
  docker-compose -f docker-compose.yml up --build
else
  error "ERROR: docker-compose must be installed - not found. Aborting..."
  exit 1
fi
