#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

trap 'rm -rf "${SCRIPT_DIR}/tmp"' EXIT

rm -rf "${SCRIPT_DIR}/tmp"
mkdir "${SCRIPT_DIR}/tmp"

git clone --depth 1 --quiet https://github.com/prometheus-operator/kube-prometheus.git "${SCRIPT_DIR}/tmp/kube-prometheus"
git clone --depth 1 --quiet https://github.com/kubernetes-monitoring/kubernetes-mixin.git "${SCRIPT_DIR}/tmp/kubernetes-mixin"
git clone --depth 1 --quiet https://github.com/etcd-io/etcd.git "${SCRIPT_DIR}/tmp/etcd"

for REPO_PATH in "${SCRIPT_DIR}/tmp/"*; do
  SHA=$(git -C "$REPO_PATH" log -1 --pretty=format:"%H")
  REPO_NAME=$(basename "$REPO_PATH")
  echo "Updating $REPO_NAME to $SHA"
  sed -i -e "s/'ref.$REPO_NAME'.*:.*'.*'/'ref.$REPO_NAME': '$SHA'/" "${SCRIPT_DIR}/sync_grafana_dashboards.py"
  sed -i -e "s/'ref.$REPO_NAME'.*:.*'.*'/'ref.$REPO_NAME': '$SHA'/" "${SCRIPT_DIR}/sync_prometheus_rules.py"
done

export PIP_DISABLE_PIP_VERSION_CHECK=1

python3 -m venv "${SCRIPT_DIR}/tmp/venv"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/tmp/venv/bin/activate"

pip3 install -r "${SCRIPT_DIR}/requirements.txt"

"${SCRIPT_DIR}/sync_grafana_dashboards.py"
"${SCRIPT_DIR}/sync_prometheus_rules.py"
