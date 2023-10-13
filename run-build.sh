#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

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
kubectl config view --flatten --minify >kubeconfig 2>/dev/null && chmod 600 kubeconfig

docker-compose -f docker-compose.yml up --build
