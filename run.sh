#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

export PUSER="$(id -un)"
export PUID="$(id -u)"
export PGID="$(id -g)"

function onExit() {
  docker-compose -f docker-compose.yml down
  rm kubeconfig
  cd "${ORIG_DIR}"
}

trap "onExit" EXIT

kubectl config view --flatten --minify >kubeconfig
chmod 600 kubeconfig

docker-compose -f docker-compose.yml up --build
