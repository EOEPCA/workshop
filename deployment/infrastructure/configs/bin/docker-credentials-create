#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

# https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials
APP_NAME="docker"
CREDS_FILE="${APP_NAME}-credentials.yaml"
SECRET_NAME="regcred"
DOCKER_CONFIG_LOC=$(readlink -f ~/.docker/config.json)

secretYaml() {
  kubectl -n "${1}" create secret generic "${SECRET_NAME}" \
    --from-file=.dockerconfigjson=${DOCKER_CONFIG_LOC} \
    --type=kubernetes.io/dockerconfigjson \
    --dry-run=client -o yaml
}

> ${CREDS_FILE}
for namespaceRequiringCreds in flux-system eoepca-system eoepca-storage rm proc um
do
  echo --- >> ${CREDS_FILE}
  # Create Secret and then pipe to kubeseal to create the SealedSecret
  secretYaml ${namespaceRequiringCreds} | kubeseal -o yaml \
    --controller-name sealed-secrets-controller \
    --controller-namespace eoepca-system >> ${CREDS_FILE}
done


