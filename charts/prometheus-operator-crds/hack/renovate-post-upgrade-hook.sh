#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${0}")" &>/dev/null && pwd)"

"${SCRIPT_DIR}/update_crds.sh"
