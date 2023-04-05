#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="minio-credentials"
NAMESPACE="eoepca-object-storage"

ROOT_USER={1:-admin}
ROOT_PWD=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 64  ; echo)

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal="rootUser=$(ROOT_USER)" \
    --from-literal="rootPassword=$(ROOT_PWD)" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml \
  --namespace=${NAMESPACE} \
  --controller-name sealed-secrets-controller \
  --controller-namespace eoepca-system > minio-credentials.yaml
