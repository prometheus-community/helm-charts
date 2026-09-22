#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CHART_DIR=$(cd -- "${SCRIPT_DIR}/.." && pwd)
REPOSITORY_ROOT=$(cd -- "${CHART_DIR}/../.." && pwd)
VALUES_FILE="${SCRIPT_DIR}/09-relationship-values.yaml"
CONTRACT_DIR="${SCRIPT_DIR}/iac-guard-v"
WORK_DIR=$(mktemp -d)
RENDER_ONE="${WORK_DIR}/render-one"
RENDER_TWO="${WORK_DIR}/render-two"

trap 'rm -rf "${WORK_DIR}"' EXIT

render_chart() {
  local output_dir=$1

  helm template relationship-check "${CHART_DIR}" \
    --namespace monitoring \
    --kube-version 1.34.0 \
    --values "${VALUES_FILE}" \
    --output-dir "${output_dir}" >/dev/null
}

render_chart "${RENDER_ONE}"
render_chart "${RENDER_TWO}"
diff --recursive --brief "${RENDER_ONE}" "${RENDER_TWO}"

for contract in "${CONTRACT_DIR}/monitoring-contract.yaml" "${CONTRACT_DIR}/rbac-contract.yaml"; do
  report="${WORK_DIR}/$(basename "${contract}" .yaml)-report.json"

  iac-guard contract lint --contract "${contract}"
  iac-guard contract plan \
    --contract "${contract}" \
    --project-root "${REPOSITORY_ROOT}" \
    --contract-root "${RENDER_ONE}" \
    --contract-provenance RESEARCH_HYPOTHESIS \
    --quiet
  iac-guard verify \
    --contract "${contract}" \
    --project-root "${REPOSITORY_ROOT}" \
    --contract-root "${RENDER_ONE}" \
    --contract-provenance RESEARCH_HYPOTHESIS \
    --format json \
    --output "${report}" \
    --quiet
  iac-guard explain "${report}" --format console
done
