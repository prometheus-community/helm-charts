#!/usr/bin/env bash

set -euo pipefail

{
  SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

  cd "${SCRIPT_DIR}/../"

  ./hack/sync_grafana_dashboard.sh
  if ! git diff "${GITHUB_SHA:-HEAD}" --color=always --exit-code; then
    echo "Please run ./hack/sync_grafana_dashboard.sh"
    exit 1
  fi
} 2>&1
