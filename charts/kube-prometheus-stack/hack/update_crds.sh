#!/bin/bash -eu

VERSION=$1

[ -z "${VERSION}" ] && echo "Pass prometheus-operator version as first comandline argument" && exit 1

FILES=(
  "crd-alertmanagerconfigs.yaml :  monitoring.coreos.com_alertmanagerconfigs.yaml"
  "crd-alertmanagers.yaml       :  monitoring.coreos.com_alertmanagers.yaml"
  "crd-podmonitors.yaml         :  monitoring.coreos.com_podmonitors.yaml"
  "crd-probes.yaml              :  monitoring.coreos.com_probes.yaml"
  "crd-prometheuses.yaml        :  monitoring.coreos.com_prometheuses.yaml"
  "crd-prometheusrules.yaml     :  monitoring.coreos.com_prometheusrules.yaml"
  "crd-servicemonitors.yaml     :  monitoring.coreos.com_servicemonitors.yaml"
  "crd-thanosrulers.yaml        :  monitoring.coreos.com_thanosrulers.yaml"
)

for line in "${FILES[@]}" ; do
    DESTINATION=$(echo "${line%%:*}" | xargs)
    SOURCE=$(echo "${line##*:}" | xargs)

    URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/$SOURCE"
    echo "# ${URL}" > ../crds/"${DESTINATION}"
    curl -L "${URL}" >> ../crds/"${DESTINATION}"
    # CRD is too long
    # https://github.com/prometheus-community/helm-charts/issues/1500
    if [ "$SOURCE" = monitoring.coreos.com_prometheuses.yaml ]; then
      sed -i 's@^  annotations:@  annotations:\n    argocd.argoproj.io/sync-options: Replace=true@' ../crds/"${DESTINATION}"
    fi
done
