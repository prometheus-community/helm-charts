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

_TAR=$(which tar 2>/dev/null)

cd "${SCRIPT_DIR}/../charts/crds/crds/"

case $($_TAR --help) in
  *GNU*)
    find crd-*.yaml -print0 | sort -z | env XZ_OPT=-9 $_TAR --sort=name --format=ustar \
      --mtime="@0" \
      --numeric-owner --owner=0 --group=0 \
      --mode='go+u,go-w' \
      --no-xattrs --no-acls --no-selinux \
      --no-recursion --null --files-from - \
      -cJpf ../files/crds.tar.xz
    ;;
  *)
    find crd-*.yaml -exec touch -d 1970-01-01T00:00:00Z {} + -print0 | sort -z | env COPYFILE_DISABLE=1 $_TAR --format=ustar \
      --numeric-owner --uid=0 --gid=0 \
      --no-xattrs \
      --no-recursion --null --files-from - \
      --options xz:compression-level=9 \
      -cJf ../files/crds.tar.xz
    ;;
esac
