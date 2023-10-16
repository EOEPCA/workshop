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
    docker run --rm --name jupyterlab \
      --user root \
      -p 8888:8888 \
      -v ${PWD}/workshop:/home/${NB_USER}/work \
      -e NB_USER="${NB_USER}" \
      -e NB_UID="${NB_UID}" \
      -e NB_GID="${NB_GID}" \
      -e CHOWN_HOME="yes" \
      -e JUPYTER_ENABLE_LAB="yes" \
      eoepca/workshop \
      start-notebook.sh --NotebookApp.token=\'\'
  else
    error "ERROR: docker must be installed - not found. Aborting..."
    return 1
  fi
}

main "$@"
