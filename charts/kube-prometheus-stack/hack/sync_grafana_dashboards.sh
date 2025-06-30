#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${0}")" &>/dev/null && pwd)

if ! which jb &>/dev/null; then
  if ! which go &>/dev/null; then
    echo "'jb' command not found & cannot be installed because go is missing too"
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

cd "${SCRIPT_DIR}"

go run ./cmd/dashboards/main.go
