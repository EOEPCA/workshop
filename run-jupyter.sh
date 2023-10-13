#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

export EXPOSE_PORT="${1:-8888}"

export NB_USER="$(id -un)"
export NB_UID="$(id -u)"
export NB_GID="$(id -g)"

function onExit() {
  cd "${ORIG_DIR}"
}
trap "onExit" EXIT

export PYDEVD_DISABLE_FILE_VALIDATION=1

python -m venv venv
source venv/bin/activate
python -m pip install -U pip
pip install -U devtools
pip install -U cmake
pip install -U wheel setuptools
pip install -U jupyterlab
pip install -r workshop/requirements.txt
jupyter-lab --ServerApp.root_dir workshop --NotebookApp.token=\'\' --no-browser
