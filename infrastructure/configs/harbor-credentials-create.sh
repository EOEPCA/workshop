#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

APP_NAME="harbor"
CREDS_FILE="${APP_NAME}-credentials.yaml"
SECRET_NAME="${APP_NAME}-credentials"
NAMESPACE="eoepca-storage"

randomCharacters() {
  length=$1
  tr -dc 'A-Za-z0-9!#%&()*+,-<>?@^_`{}~' </dev/urandom | head -c $length  ; echo
}

ROOT_PWD=$(randomCharacters 64)

secretYaml() {
  kubectl -n "${1}" create secret generic "${SECRET_NAME}" \
    --from-literal="password=$ROOT_PWD" \
    --dry-run=client -o yaml
}

> ${CREDS_FILE}
for namespaceRequiringCreds in eoepca-storage
do
  echo --- >> ${CREDS_FILE}
  # Create Secret and then pipe to kubeseal to create the SealedSecret
  secretYaml ${namespaceRequiringCreds} | kubeseal -o yaml \
    --namespace=${NAMESPACE} \
    --controller-name sealed-secrets-controller \
    --controller-namespace eoepca-system >> ${CREDS_FILE}
done


