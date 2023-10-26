#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
source functions

TARGET_PYTHON_MAJOR=3
TARGET_PYTHON_MINOR=9
PYTHON_VERSION=${TARGET_PYTHON_MAJOR}.${TARGET_PYTHON_MINOR}

export NB_USER="$(id -un)"
export NB_UID="$(id -u)"
export NB_GID="$(id -g)"

function onExit() { cd "${ORIG_DIR}"; }
trap "onExit" EXIT

main() {
  optionalClean "$@"
  if deducePythonVersion; then
    runWithPython
  fi
}

runWithPython() {
  info "Using python command - $(which $PYTHON)"
  $PYTHON -m venv venv \
    && source venv/bin/activate \
    && pip install -U jupyterlab \
    && pip install -r workshop/requirements.txt \
    && jupyter-lab --ServerApp.root_dir workshop --NotebookApp.token=\'\' --no-browser
}

deducePythonVersion() {  
  PYTHON_MATCH=no
  for p in fred python python${TARGET_PYTHON_MAJOR} python${PYTHON_VERSION}; do
    if hash $p 2>/dev/null; then
      export PYTHON=$p
      if test ${PYTHON_VERSION} == $($p -V | cut -d ' ' -f 2 | cut -d '.' -f -2); then
        export PYTHON_MATCH=yes
        break
      fi
    fi
  done
  if [ "${PYTHON_MATCH}" != "yes" ]; then
    if test -n "${PYTHON}"; then
      warning "WARNING: can't find python ${PYTHON_VERSION}. Using the best alternative found..."
    else
      error "ERROR: can't find python ${PYTHON_VERSION}. Aborting..."
      return 1
    fi
  fi
  return 0
}

optionalClean() {
  if [[ "$*" == *"--clean"* ]]; then
    warning "Clean: removing existing venv"
    rm -rf venv
  else
    if test -d venv; then info "Using existing venv in directory $PWD/venv\n  -> Use option --clean to create a fresh environment"; fi
  fi
}

main "$@"
