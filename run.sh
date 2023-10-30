#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
source functions

export EXPOSE_PORT="${1:-8888}"

export NB_USER="$(id -un)"
export NB_UID="$(id -u)"
export NB_GID="$(id -g)"

function onExit() {
  cd "${ORIG_DIR}"
}
trap "onExit" EXIT

main() {
  runWithDocker
}

runWithDocker() {
  if hash docker 2>/dev/null; then
    docker run --rm -it --name jupyterlab \
      -p ${EXPOSE_PORT}:8888 \
      -v ${PWD}/workshop:/app/workshop \
      eoepca/workshop \
      run-jupyter.sh
  else
    error "ERROR: docker must be installed - not found. Aborting..."
    return 1
  fi
}

main "$@"
