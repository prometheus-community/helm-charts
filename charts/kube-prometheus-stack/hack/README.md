# kube-prometheus-stack hacks

## [sync_prometheus_rules.py](sync_prometheus_rules.py)

This script generates prometheus rules set for alertmanager from any properly formatted kubernetes yaml based on defined input, splitting rules to separate files based on group name.

Currently following imported:

- [prometheus-operator/kube-prometheus rules set](https://github.com/prometheus-operator/kube-prometheus/tree/main/manifests/kubernetes-prometheusRule.yaml)
  - In order to modify these rules:
    - prepare and merge PR into [kubernetes-mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/rules) master and/or release branch
    - run import inside your fork of [prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/tree/main)

     ```bash
     jb update
     make generate
     ```

    - prepare and merge PR with imported changes into `prometheus-operator/kube-prometheus` master and/or release branch
    - run sync_prometheus_rules.py inside your fork of this repo
    - send PR with changes to this repo
- [etcd-io/website rules set](https://github.com/etcd-io/website/tree/master/content/docs/v3.4.0/etcd-mixin/README.md)
  - In order to modify these rules:
    - prepare and merge PR into [etcd-io/website](https://github.com/etcd-io/website/blob/master/content/docs/v3.4.0/etcd-mixin/mixin.libsonnet) repo
    - run sync_prometheus_rules.py inside your fork of this repo
    - send PR with changes to this repo

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
    - run sync_grafana_dashboards.py inside your fork of this repo
    - send PR with changes to this repo
- [etcd-io/website dashboard](https://github.com/etcd-io/website/blob/master/content/docs/v3.4.0/op-guide/grafana.json)
  - In order to modify this dashboard:
    - prepare and merge PR into [etcd-io/website](https://github.com/etcd-io/website/blob/master/content/docs/v3.4.0/op-guide/grafana.json) repo
    - run sync_grafana_dashboards.py inside your fork of this repo
    - send PR with changes to this repo

[CoreDNS dashboard](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/k8s-coredns.yaml) is the only dashboard which is maintained in this repo and can be changed without import.
