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

# Copy the local kubeconfig file into the cluster for kubectl access from within notebooks.
kubectl config view --flatten --minify >kubeconfig
chmod 600 kubeconfig

# Need to join the minikube network for kubectl to work from within Notebooks.
# In the case that Jupyter is not run locally to the running minikube then this
# will not work, but we still need to ensure that the network named minikube
# exists since it is referenced by the docker-compose file.
# If the network already exists (e.g. if minikube is running) then this does no harm.
docker network create minikube 2>/dev/null

docker-compose -f docker-compose.yml up --build
