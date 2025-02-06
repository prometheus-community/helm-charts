# kube-prometheus-stack hacks

## [update_mixins.sh](update_mixins.sh)

This script is a useful wrapper to run `sync_prometheus_rules.py` and
`sync_grafana_dashboards.py`.

It clones all dependency dashboards into a tmp folder.

And it lets you know if you are missing commandline-tools necessary for the
update to complete.

Therefore, if you want to create a PR that updates the mixins, please
run `./hack/update_mixins.sh` from the charts directory
(`./charts/kube-prometheus-stack`).

## [sync_prometheus_rules.py](sync_prometheus_rules.py)

This script generates prometheus rules set for alertmanager from any properly formatted kubernetes YAML based on defined input, splitting rules to separate files based on group name.

Currently following imported:

- [prometheus-operator/kube-prometheus rules set](https://github.com/prometheus-operator/kube-prometheus/blob/main/manifests/kubernetesControlPlane-prometheusRule.yaml)
  - In order to modify these rules:
    - prepare and merge PR into [kubernetes-mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/rules) master and/or release branch
    - run import inside your fork of [prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/tree/main)

     ```bash
     jb update
     make generate
     ```

    - prepare and merge PR with imported changes into `prometheus-operator/kube-prometheus` master and/or release branch
    - run sync_prometheus_rules.py inside your fork of this repository
    - send PR with changes to this repository
- [etcd-io/etcd rules set](https://github.com/etcd-io/etcd/blob/main/contrib/mixin/mixin.libsonnet).
  - In order to modify these rules:
    - prepare and merge PR into [etcd-io/etcd](https://github.com/etcd-io/etcd/blob/main/contrib/mixin/mixin.libsonnet) repository
    - run sync_prometheus_rules.py inside your fork of this repository
    - send PR with changes to this repository

## [sync_grafana_dashboards.py](sync_grafana_dashboards.py)

This script generates grafana dashboards from json files, splitting them to separate files based on group name.

Currently following imported:

- [prometheus-operator/kube-prometheus dashboards](https://github.com/prometheus-operator/kube-prometheus/tree/main/manifests/grafana-deployment.yaml)
  - In order to modify these dashboards:
    - prepare and merge PR into [kubernetes-mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/dashboards) master and/or release branch
    - run import inside your fork of [prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/tree/main)

     ```bash
     jb update
     make generate
     ```

    - prepare and merge PR with imported changes into `prometheus-operator/kube-prometheus` master and/or release branch
    - run sync_grafana_dashboards.py inside your fork of this repository
    - send PR with changes to this repository

<!-- textlint-disable -->

- [etcd-io/website dashboard](https://github.com/etcd-io/etcd/blob/main/contrib/mixin/mixin.libsonnet)
  - In order to modify this dashboard:
    - prepare and merge PR into [etcd-io/etcd](https://github.com/etcd-io/etcd/blob/main/contrib/mixin/mixin.libsonnet) repository
    - run sync_grafana_dashboards.py inside your fork of this repository
    - send PR with changes to this repository

<!-- textlint-enable -->

[CoreDNS dashboard](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/k8s-coredns.yaml) is the only dashboard which is maintained in this repository and can be changed without import.
