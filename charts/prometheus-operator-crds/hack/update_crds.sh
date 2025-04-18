#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [[ $(uname -s) = "Darwin" ]]; then
  VERSION="$(grep ^appVersion "${SCRIPT_DIR}/../Chart.yaml" | sed 's/appVersion: //g')"
else
  VERSION="$(grep ^appVersion "${SCRIPT_DIR}/../Chart.yaml" | sed 's/appVersion:\s//g')"
fi

CRDS=(
  "alertmanagerconfigs :  monitoring.coreos.com_alertmanagerconfigs.yaml"
  "alertmanagers       :  monitoring.coreos.com_alertmanagers.yaml"
  "podmonitors         :  monitoring.coreos.com_podmonitors.yaml"
  "probes              :  monitoring.coreos.com_probes.yaml"
  "prometheusagents    :  monitoring.coreos.com_prometheusagents.yaml"
  "prometheuses        :  monitoring.coreos.com_prometheuses.yaml"
  "prometheusrules     :  monitoring.coreos.com_prometheusrules.yaml"
  "scrapeconfigs       :  monitoring.coreos.com_scrapeconfigs.yaml"
  "servicemonitors     :  monitoring.coreos.com_servicemonitors.yaml"
  "thanosrulers        :  monitoring.coreos.com_thanosrulers.yaml"
)

for line in "${CRDS[@]}"; do
  CRD=$(echo "${line%%:*}" | xargs)
  SOURCE=$(echo "${line##*:}" | xargs)
  DESTINATION="crd-${CRD}".yaml

  URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/$SOURCE"

  echo -e "Downloading Prometheus Operator CRD with Version ${VERSION}:\n${URL}\n"

  echo "# ${URL}" >"${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}"

  if ! curl --silent --retry-all-errors --fail --location "${URL}" >>"${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}"; then
    echo -e "Failed to download ${URL}!"
    exit 1
  fi

  # Update or insert annotations block
  if yq -e '.metadata.annotations' "${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}" >/dev/null; then
    sed -i '/^  annotations:$/a {{- with .Values.annotations }}\n{{- toYaml . | nindent 4 }}\n{{- end }}' "${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}"
  else
    sed -i '/^metadata:$/a {{- with .Values.annotations }}\n  annotations:\n{{- toYaml . | nindent 4 }}\n{{- end }}' "${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}"
  fi

  # Insert enable option
  sed -i "1i\{{- if .Values.${CRD}.enabled -}}" "${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}"
  echo "{{- end -}}" >>"${SCRIPT_DIR}/../charts/crds/templates/${DESTINATION}"
done
