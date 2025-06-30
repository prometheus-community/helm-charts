#!/usr/bin/env bash

set -euo pipefail

if ! which jb &>/dev/null; then
  echo "'jb' command not found
Install jsonnet-bundler from https://github.com/jsonnet-bundler/jsonnet-bundler"
  exit 1
fi

if ! which go &>/dev/null; then
  echo "'go' command not found"
  exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

trap 'rm -rf "${SCRIPT_DIR}/tmp"' EXIT

rm -rf "${SCRIPT_DIR}/tmp"
mkdir "${SCRIPT_DIR}/tmp"

cd "${SCRIPT_DIR}"

# Run mixins command to update refs.yaml
go run "${SCRIPT_DIR}/cmd/mixins/main.go"

# Run dashboards/rules to build from refs.yaml
go run "${SCRIPT_DIR}/cmd/dashboards/main.go"
go run "${SCRIPT_DIR}/cmd/rules/main.go"