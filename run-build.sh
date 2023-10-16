#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
source functions

export EXPOSE_PORT="${1:-8888}"

export PUSER="$(id -un)"
export PUID="$(id -u)"
export PGID="$(id -g)"

function onExit() {
  docker-compose -f docker-compose.yml down
  rm -f kubeconfig
  cd "${ORIG_DIR}"
}
trap "onExit" EXIT

# Copy the local kubeconfig file into the cluster for kubectl access from within notebooks.
if hash kubectl 2>/dev/null; then
  kubectl config view --flatten --minify >kubeconfig 2>/dev/null && chmod 600 kubeconfig
fi

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
