#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${0}")" &>/dev/null && pwd)

if ! which jb &>/dev/null; then
  if ! which go &>/dev/null; then
    echo "'jb' command not found"
    echo "Install jsonnet-bundler from https://github.com/jsonnet-bundler/jsonnet-bundler"
    exit 1
  fi

  echo "'jb' command not found. Try to install it from github.com/jsonnet-bundler/jsonnet-bundler"

  go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
  PATH="$(go env GOPATH)/bin:$PATH"
  export PATH

  if ! which jb &>/dev/null; then
    echo "'jb' command not found"
    echo "Install jsonnet-bundler from https://github.com/jsonnet-bundler/jsonnet-bundler"
    exit 1
  fi
fi

rm -rf "${SCRIPT_DIR}/tmp"
mkdir "${SCRIPT_DIR}/tmp"

export PIP_DISABLE_PIP_VERSION_CHECK=1

python3 -m venv "${SCRIPT_DIR}/tmp/venv"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/tmp/venv/bin/activate"

pip3 install -r "${SCRIPT_DIR}/requirements.txt"

"${SCRIPT_DIR}/sync_grafana_dashboards.py"
"${SCRIPT_DIR}/sync_prometheus_rules.py"
