#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
source functions

function onExit() { cd "${ORIG_DIR}"; }
trap "onExit" EXIT

startJupyterLab "$@"
