#!/bin/bash

set -e

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

    URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/$SOURCE"

    echo -e "Downloading Prometheus Operator CRD with Version ${VERSION}:\n${URL}\n"

    echo "# ${URL}" > "${SCRIPT_DIR}/../charts/crds/crds/${DESTINATION}"

    if ! curl --silent --retry-all-errors --fail --location "${URL}" >> "${SCRIPT_DIR}/../charts/crds/crds/${DESTINATION}"; then
      echo -e "Failed to download ${URL}!"
      exit 1
    fi
done

cd "${SCRIPT_DIR}/../charts/crds/crds/"

# COPYFILE_DISABLE is used to prevent tar from including BSD metadata in the tarball
# ref: https://unix.stackexchange.com/a/282142/433641
env COPYFILE_DISABLE=1 tar cJf ../files/crds.tar.xz crd-*
