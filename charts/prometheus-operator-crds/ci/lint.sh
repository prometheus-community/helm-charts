#!/usr/bin/env bash

set -euo pipefail

{
    SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

    cd "${SCRIPT_DIR}/../"

    ./hack/update_crds.sh
    if ! git diff "$GITHUB_SHA" --color=always --exit-code; then
      echo "Please run ./hack/update_crds.sh"
      exit 1
    fi
} 2>&1
