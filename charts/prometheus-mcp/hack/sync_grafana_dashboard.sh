#!/usr/bin/env bash
# Sync the Grafana dashboard from the upstream prometheus-mcp repository at the
# chart's appVersion. ci/lint.sh runs it and fails on any resulting diff.
#
# usage: hack/sync_grafana_dashboard.sh
#
#   DASHBOARD_REF  upstream git ref to sync from (default: Chart.yaml appVersion);
#                  a tag, branch, commit or refs/pull/<n>/head
#   DASHBOARD_URL  full URL of the dashboard file; overrides DASHBOARD_REF, for
#                  syncing from a fork
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

dest=dashboards/prometheus-mcp-dashboard.json
repo=https://raw.githubusercontent.com/prometheus/prometheus-mcp
ref=${DASHBOARD_REF:-$(sed -n 's/^appVersion: *"\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' Chart.yaml)}
url=${DASHBOARD_URL:-$repo/$ref/grafana/prometheus-mcp-dashboard.json}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

status=$(curl -sSL -o "$tmp" -w '%{http_code}' "$url")
case $status in
200) ;;
404)
  # The chart may ship a dashboard ahead of the release it deploys, but the
  # ref itself must exist so a typo cannot pass as "not released yet".
  if [ -z "${DASHBOARD_URL:-}" ] && curl -sSfL -o /dev/null "$repo/$ref/VERSION"; then
    echo "upstream has no grafana/prometheus-mcp-dashboard.json at $ref; the chart copy leads"
    exit 0
  fi
  echo "$url: not found" >&2
  exit 1
  ;;
*)
  echo "$url: HTTP $status" >&2
  exit 1
  ;;
esac

cp "$tmp" "$dest"
echo "synced $dest from $url"
