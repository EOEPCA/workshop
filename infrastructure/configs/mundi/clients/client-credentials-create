#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

main() {
  processArgs "$@"
  checkDocker
  registerClient
  createClientSecret
}


usage() {
  echo "Usage:"
  echo "./deploy-to-cluster [options]"
  echo " "
  echo "options                                 | Required | Default                  | Description"
  echo "-h, --help                              | false    | N/A                      | Show this description"
  echo "-n, --namespace <namespace>             | true     |                          | The namespace in which to store the client crential secrets in"
  echo "-a, --auth_server <auth server address> | true     | auth.workshop.eoepca.org | The address of the auth server to register the client with"
  echo "-c, --client <client name>              | true     |                          | The name of the client"
  echo "-r, --redirect_uri <redirect uri>       | false    |                          | The redirect uri"
  echo "-l, --login_uri <rlogin uri>            | false    |                          | The login uri"
  echo
}

setDefaults() {
  auth_server="auth.workshop.eoepca.org"
}

processArgs() {
  setDefaults

  while [ $# -gt 0 ]; do
    case "$1" in
      "-n" | "--namespace")
        shift
        namespace="${1}"
        ;;
      "-a" | "--auth_server")
        shift
        auth_server="${1}"
        ;;
      "-c" | "--client")
        shift
        client_name="${1}"
        ;;
      "-r" | "--redirect_uri")
        shift
        redirect_uri="${1}"
        ;;
      "-l" | "--login_uri")
        shift
        login_uri="${1}"
        ;;
      "-h" | "--help")
        usage
        exit 0
        ;;
      *)
        echo "ERROR: Invalid argument ${1}" 1>&2
        usage
        exit 1
        ;;
    esac
    shift
  done

  validateArgs
}

validateArgs() {
  if [ -z "${namespace}" ]; then
    echo "ERROR: namespace must be set"
    usage
    exit 1
  fi
  if [ -z "${auth_server}" ]; then
    echo "ERROR: auth_server must be set"
    usage
    exit 1
  fi
  if [ -z "${client_name}" ]; then
    echo "ERROR: client must be set"
    usage
    exit 1
  fi
}

# Check docker is installed
checkDocker() {
  if ! hash docker >/dev/null 2>&1; then
    printMsg "ERROR: docker is required" 1>&2
    exit 1
  fi
}

registerClient() {
  pushd "${ORIG_DIR}" >/dev/null
  registerOutput=$(docker run --rm ${docker_network} eoepca/client-utils "register-client ${auth_server} \"${client_name}\" ${redirect_uri} ${logout_uri}")
  popd >/dev/null
}

secretYaml() {
  kubectl -n "${1}" create secret generic "${client_name}-uma-user-agent" \
    --from-literal="client.yaml=${registerOutput}" \
    --dry-run=client -o yaml
}

createClientSecret() {
  CREDS_FILE="${client_name}-client-credentials.yaml"
  > ${CREDS_FILE}
  for namespaceRequiringCreds in ${namespace}
  do
    echo --- >> ${CREDS_FILE}
    # Create Secret and then pipe to kubeseal to create the SealedSecret
    secretYaml ${namespaceRequiringCreds} | kubeseal -o yaml \
      --controller-name sealed-secrets-controller \
      --controller-namespace eoepca-system >> ${CREDS_FILE}
  done
}

main "$@"