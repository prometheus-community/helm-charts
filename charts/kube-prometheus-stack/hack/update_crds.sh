#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ $(uname -s) = "Darwin" ]]; then
    VERSION="$(grep ^appVersion "${SCRIPT_DIR}/../Chart.yaml" | sed 's/appVersion: //g')"
else
    VERSION="$(grep ^appVersion "${SCRIPT_DIR}/../Chart.yaml" | sed 's/appVersion:\s//g')"
fi

FILES=(
  "crd-alertmanagerconfigs.yaml :  monitoring.coreos.com_alertmanagerconfigs.yaml"
  "crd-alertmanagers.yaml       :  monitoring.coreos.com_alertmanagers.yaml"
  "crd-podmonitors.yaml         :  monitoring.coreos.com_podmonitors.yaml"
  "crd-probes.yaml              :  monitoring.coreos.com_probes.yaml"
  "crd-prometheusagents.yaml    :  monitoring.coreos.com_prometheusagents.yaml"
  "crd-prometheuses.yaml        :  monitoring.coreos.com_prometheuses.yaml"
  "crd-prometheusrules.yaml     :  monitoring.coreos.com_prometheusrules.yaml"
  "crd-scrapeconfigs.yaml       :  monitoring.coreos.com_scrapeconfigs.yaml"
  "crd-servicemonitors.yaml     :  monitoring.coreos.com_servicemonitors.yaml"
  "crd-thanosrulers.yaml        :  monitoring.coreos.com_thanosrulers.yaml"
)

for line in "${FILES[@]}"; do
    DESTINATION=$(echo "${line%%:*}" | xargs)
    SOURCE=$(echo "${line##*:}" | xargs)

    URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd-full/$SOURCE"

    echo -e "Downloading Prometheus Operator CRD with Version ${VERSION}:\n${URL}\n"

    echo "# ${URL}" > "${SCRIPT_DIR}/../charts/crds/crds/${DESTINATION}"

    if ! curl --silent --retry-all-errors --fail --location "${URL}" >> "${SCRIPT_DIR}/../charts/crds/crds/${DESTINATION}"; then
      echo -e "Failed to download ${URL}!"
      exit 1
    fi
done

if ! curl --silent --retry-all-errors --fail --location "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/alertmanager-crd-conversion/patch.json" >> "${SCRIPT_DIR}/../charts/crds/crds/patch.json"; then
  echo -e "Failed to download ${URL}!"
  exit 1
fi

{
  head -n1 "${SCRIPT_DIR}/../charts/crds/crds/crd-alertmanagerconfigs.yaml";
  kubectl patch --local=true -f "${SCRIPT_DIR}/../charts/crds/crds/crd-alertmanagerconfigs.yaml" --patch-file="${SCRIPT_DIR}/../charts/crds/crds/patch.json" --type=merge --dry-run=client -o yaml
} >"${SCRIPT_DIR}/../charts/crds/crds/crd-alertmanagerconfigs.patched.yaml"

rm "${SCRIPT_DIR}/../charts/crds/crds/patch.json"
mv "${SCRIPT_DIR}/../charts/crds/crds/crd-alertmanagerconfigs.patched.yaml" "${SCRIPT_DIR}/../charts/crds/crds/crd-alertmanagerconfigs.yaml"