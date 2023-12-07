#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}/../"

./hack/update_crds.sh
if ! git diff --exit-code; then
  echo "Please run ./hack/update_crds.sh"
  exit 1
fi

python3 -m venv venv
source venv/bin/activate
pip3 install -r hack/requirements.txt

go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
export PATH="$(go env GOPATH)/bin:$PATH"

./hack/sync_prometheus_rules.py
if ! git diff --exit-code; then
  echo "Changes inside rules are not supported!"
  echo "Please run ./hack/sync_prometheus_rules.py"
  exit 1
fi

./hack/sync_grafana_dashboards.py
if ! git diff --exit-code; then
  echo "Changes inside dashboards are not supported!"
  echo "Please run ./hack/sync_grafana_dashboards.py"
  exit 1
fi

rm -rf ./venv ./*.git
