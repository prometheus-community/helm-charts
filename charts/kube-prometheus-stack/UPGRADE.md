# Upgrade

## From 69.x to 70.x

This version upgrades Prometheus-Operator to v0.81.0 now supporting serviceName for Prometheus/AM/ThanosRuler CRDs. If empty there is no changes to the creation of an operated service. If defined operated service will not be created and new serviceName will be used as governing service.

Since [68.4.0](https://github.com/prometheus-community/helm-charts/pull/5175) it is also possible to use `crds.upgradeJob.enabled` for upgrading the CRDs.
For traditional upgrades, please run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.81.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 68.x to 69.x

This version upgrades Prometheus-Operator to v0.80.0
Since [68.4.0](https://github.com/prometheus-community/helm-charts/pull/5175) it is also possible to use `crds.upgradeJob.enabled` for upgrading the CRDs.
For traditional upgrades, please run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.80.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 67.x to 68.x

This version drops several metrics by default in order to reduce unnecessary cardinality.

This version also fixes histogram bucket matching for Prometheus 3.x.

From `{job="apiserver"}` drop excessive histogram buckets for the following metrics:

- `apiserver_request_sli_duration_seconds_bucket`
- `apiserver_request_slo_duration_seconds_bucket`
- `etcd_request_duration_seconds_bucket`

From `{job="kubelet",metrics_path="/metrics"}` reduce bucket cardinality of kubelet storage operations:

- `csi_operations_seconds_bucket`
- `storage_operation_duration_seconds_bucket`

From `{job="kubelet",metrics_path="/metrics/cadvisor"}`:

- Drop `container_memory_failures_total{scope="hierarchy"}` metrics, we only need the container scope here.
- Drop `container_network_...` metrics that match various interfaces correspond to CNI and similar interfaces.

## From 66.x to 67.x

This version upgrades Prometheus Image to v3.0.1 as it is the default version starting with operator version v0.79.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 65.x to 66.x

This version upgrades Prometheus-Operator to v0.78.1

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 64.x to 65.x

This version upgrades Prometheus-Operator to v0.77.1

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 63.x to 64.x

v64 reverts the v63 release.

All changes mentioned in the v63 release notes must be reverted.

## From 62.x to 63.x

Simplify setting empty selectors, by deprecating `*SelectorNilUsesHelmValues` properties.  
Instead, setting `*Selector.matchLabels=null` will create an empty selector.

If you set one of the following properties to `false`, you will have to convert them:

- `prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues`
- `prometheus.prometheusSpec.probeSelectorNilUsesHelmValues`
- `prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues`
- `prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues`
- `prometheus.prometheusSpec.scrapeConfigSelectorNilUsesHelmValues`
- `thanosRuler.thanosRulerSpec.ruleSelectorNilUsesHelmValues`

For example:

```yaml
prometheus:
  prometheusSpec:
    scrapeConfigSelectorNilUsesHelmValues: false
```

Becomes:

```yaml
prometheus:
  prometheusSpec:
    scrapeConfigSelector:
      matchLabels: null
```

Note that `externalPrefixNilUsesHelmValues` remains as is.

## From 61.x to 62.x

This version upgrades Prometheus-Operator to v0.76.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 60.x to 61.x

This version upgrades Prometheus-Operator to v0.75.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.75.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 59.x to 60.x

This version upgrades the Grafana chart to v8.0.x which introduces Grafana 11. This new major version of Grafana contains some breaking changes described in [Breaking changes in Grafana v11.0](https://grafana.com/docs/grafana/latest/breaking-changes/breaking-changes-v11-0/).

## From 58.x to 59.x

This version upgrades Prometheus-Operator to v0.74.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 57.x to 58.x

This version upgrades Prometheus-Operator to v0.73.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 56.x to 57.x

This version upgrades Prometheus-Operator to v0.72.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.72.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 55.x to 56.x

This version upgrades Prometheus-Operator to v0.71.0, Prometheus to 2.49.1

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 54.x to 55.x

This version upgrades Prometheus-Operator to v0.70.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.70.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 53.x to 54.x

Grafana Helm Chart has bumped to version 7

Please note Grafana Helm Chart [changelog](https://github.com/grafana/helm-charts/tree/main/charts/grafana#to-700).

## From 52.x to 53.x

This version upgrades Prometheus-Operator to v0.69.1, Prometheus to 2.47.2

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.69.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 51.x to 52.x

This includes the ability to select between using existing secrets or create new secret objects for various thanos config. The defaults have not changed but if you were setting:

- `thanosRuler.thanosRulerSpec.alertmanagersConfig` or
- `thanosRuler.thanosRulerSpec.objectStorageConfig` or
- `thanosRuler.thanosRulerSpec.queryConfig` or
- `prometheus.prometheusSpec.thanos.objectStorageConfig`

you will have to need to set `existingSecret` or `secret` based on your requirement

For instance, the `thanosRuler.thanosRulerSpec.alertmanagersConfig` used to be configured as follow:

```yaml
thanosRuler:
  thanosRulerSpec:
    alertmanagersConfig:
      alertmanagers:
        - api_version: v2
          http_config:
            basic_auth:
              username: some_user
              password: some_pass
          static_configs:
            - alertmanager.thanos.io
          scheme: http
          timeout: 10s
```

But it now moved to:

```yaml
thanosRuler:
  thanosRulerSpec:
    alertmanagersConfig:
      secret:
        alertmanagers:
          - api_version: v2
            http_config:
              basic_auth:
                username: some_user
                password: some_pass
            static_configs:
              - alertmanager.thanos.io
            scheme: http
            timeout: 10s
```

or the `thanosRuler.thanosRulerSpec.objectStorageConfig` used to be configured as follow:

```yaml
thanosRuler:
  thanosRulerSpec:
    objectStorageConfig:
      name: existing-secret-not-created-by-this-chart
      key: object-storage-configs.yaml
```

But it now moved to:

```yaml
thanosRuler:
  thanosRulerSpec:
    objectStorageConfig:
      existingSecret:
        name: existing-secret-not-created-by-this-chart
        key: object-storage-configs.yaml
```

## From 50.x to 51.x

This version upgrades Prometheus-Operator to v0.68.0, Prometheus to 2.47.0 and Thanos to v0.32.2

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 49.x to 50.x

This version requires Kubernetes 1.19+.

We do not expect any breaking changes in this version.

## From 48.x to 49.x

This version upgrades Prometheus-Operator to v0.67.1, 0, Alertmanager to v0.26.0, Prometheus to 2.46.0 and Thanos to v0.32.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.67.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 47.x to 48.x

This version moved all CRDs into a dedicated sub-chart. No new CRDs are introduced in this version.
See [#3548](https://github.com/prometheus-community/helm-charts/issues/3548) for more context.

We do not expect any breaking changes in this version.

## From 46.x to 47.x

This version upgrades Prometheus-Operator to v0.66.0 with new CRDs (PrometheusAgent and ScrapeConfig).

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 45.x to 46.x

This version upgrades Prometheus-Operator to v0.65.1 with new CRDs (PrometheusAgent and ScrapeConfig), Prometheus to v2.44.0 and Thanos to v0.31.0.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 44.x to 45.x

This version upgrades Prometheus-Operator to v0.63.0, Prometheus to v2.42.0 and Thanos to v0.30.2.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 43.x to 44.x

This version upgrades Prometheus-Operator to v0.62.0, Prometheus to v2.41.0 and Thanos to v0.30.1.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.62.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

If you have explicitly set `prometheusOperator.admissionWebhooks.failurePolicy`, this value is now always used even when `.prometheusOperator.admissionWebhooks.patch.enabled` is `true` (the default).

The values for `prometheusOperator.image.tag` & `prometheusOperator.prometheusConfigReloader.image.tag` are now empty by default and the Chart.yaml `appVersion` field is used instead.

## From 42.x to 43.x

This version upgrades Prometheus-Operator to v0.61.1, Prometheus to v2.40.5 and Thanos to v0.29.0.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.61.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 41.x to 42.x

This includes the overridability of container registry for all containers at the global level using `global.imageRegistry` or per container image. The defaults have not changed but if you were using a custom image, you will have to override the registry of said custom container image before you upgrade.

For instance, the prometheus-config-reloader used to be configured as follow:

```yaml
    image:
      repository: quay.io/prometheus-operator/prometheus-config-reloader
      tag: v0.60.1
      sha: ""
```

But it now moved to:

```yaml
    image:
      registry: quay.io
      repository: prometheus-operator/prometheus-config-reloader
      tag: v0.60.1
      sha: ""
```

## From 40.x to 41.x

This version upgrades Prometheus-Operator to v0.60.1, Prometheus to v2.39.1 and Thanos to v0.28.1.
This version also upgrades the Helm charts of kube-state-metrics to 4.20.2, prometheus-node-exporter to 4.3.0 and Grafana to 6.40.4.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.60.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

This version splits kubeScheduler recording and altering rules in separate config values.
Instead of `defaultRules.rules.kubeScheduler` the 2 new variables `defaultRules.rules.kubeSchedulerAlerting` and `defaultRules.rules.kubeSchedulerRecording` are used.

## From 39.x to 40.x

This version upgrades Prometheus-Operator to v0.59.1, Prometheus to v2.38.0, kube-state-metrics to v2.6.0 and Thanos to v0.28.0.
This version also upgrades the Helm charts of kube-state-metrics to 4.18.0 and prometheus-node-exporter to 4.2.0.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

Starting from prometheus-node-exporter version 4.0.0, the `node exporter` chart is using the [Kubernetes recommended labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/). Therefore you have to delete the daemonset before you upgrade.

```console
kubectl delete daemonset -l app=prometheus-node-exporter
helm upgrade -i kube-prometheus-stack prometheus-community/kube-prometheus-stack
```

If you use your own custom [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api-reference/api.md#servicemonitor) or [PodMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api-reference/api.md#podmonitor), please ensure to upgrade their `selector` fields accordingly to the new labels.

## From 38.x to 39.x

This upgraded prometheus-operator to v0.58.0 and prometheus to v2.37.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 37.x to 38.x

Reverted one of the default metrics relabelings for cAdvisor added in 36.x, due to it breaking container_network_* and various other statistics. If you do not want this change, you will need to override the `kubelet.cAdvisorMetricRelabelings`.

## From 36.x to 37.x

This includes some default metric relabelings for cAdvisor and apiserver metrics to reduce cardinality. If you do not want these defaults, you will need to override the `kubeApiServer.metricRelabelings` and or `kubelet.cAdvisorMetricRelabelings`.

## From 35.x to 36.x

This upgraded prometheus-operator to v0.57.0 and prometheus to v2.36.1

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.57.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 34.x to 35.x

This upgraded prometheus-operator to v0.56.0 and prometheus to v2.35.0

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.56.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 33.x to 34.x

This upgrades to prometheus-operator to v0.55.0 and prometheus to v2.33.5.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.55.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 32.x to 33.x

This upgrades the prometheus-node-exporter Chart to v3.0.0. Please review the changes to this subchart if you make customizations to hostMountPropagation.

## From 31.x to 32.x

This upgrades to prometheus-operator to v0.54.0 and prometheus to v2.33.1. It also changes the default for `grafana.serviceMonitor.enabled` to `true.

Run these commands to update the CRDs before applying the upgrade.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.54.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 30.x to 31.x

This version removes the built-in grafana ServiceMonitor and instead relies on the ServiceMonitor of the sub-chart.
`grafana.serviceMonitor.enabled` must be set instead of `grafana.serviceMonitor.selfMonitor` and the old ServiceMonitor may
need to be manually cleaned up after deploying the new release.

## From 29.x to 30.x

This version updates kube-state-metrics to 4.3.0 and uses the new option `kube-state-metrics.releaseLabel=true` which adds the "release" label to kube-state-metrics labels, making scraping of the metrics by kube-prometheus-stack work out of the box again, independent of the used kube-prometheus-stack release name. If you already set the "release" label via `kube-state-metrics.customLabels` you might have to remove that and use it via the new option.

## From 28.x to 29.x

This version makes scraping port for kube-controller-manager and kube-scheduler dynamic to reflect changes to default serving ports
for those components in Kubernetes versions v1.22 and v1.23 respectively.

If you deploy on clusters using version v1.22+, kube-controller-manager will be scraped over HTTPS on port 10257.

If you deploy on clusters running version v1.23+, kube-scheduler will be scraped over HTTPS on port 10259.

## From 27.x to 28.x

This version disables PodSecurityPolicies by default because they are deprecated in Kubernetes 1.21 and will be removed in Kubernetes 1.25.

If you are using PodSecurityPolicies you can enable the previous behaviour by setting `kube-state-metrics.podSecurityPolicy.enabled`, `prometheus-node-exporter.rbac.pspEnabled`, `grafana.rbac.pspEnabled` and `global.rbac.pspEnabled` to `true`.

## From 26.x to 27.x

This version splits prometheus-node-exporter chart recording and altering rules in separate config values.
Instead of `defaultRules.rules.node` the 2 new variables `defaultRules.rules.nodeExporterAlerting` and `defaultRules.rules.nodeExporterRecording` are used.

Also the following defaultRules.rules has been removed as they had no effect: `kubeApiserverError`, `kubePrometheusNodeAlerting`, `kubernetesAbsent`, `time`.

The ability to set a rubookUrl via `defaultRules.rules.rubookUrl` was reintroduced.

## From 25.x to 26.x

This version enables the prometheus-node-exporter subchart servicemonitor by default again, by setting `prometheus-node-exporter.prometheus.monitor.enabled` to `true`.

## From 24.x to 25.x

This version upgrade to prometheus-operator v0.53.1. It removes support for setting a runbookUrl, since the upstream format for runbooks changed.

```console
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.53.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 23.x to 24.x

The custom `ServiceMonitor` for the _kube-state-metrics_ & _prometheus-node-exporter_ charts have been removed in favour of the built-in sub-chart `ServiceMonitor`; for both sub-charts this means that `ServiceMonitor` customisations happen via the values passed to the chart. If you haven't directly customised this behaviour then there are no changes required to upgrade, but if you have please read the following.

For _kube-state-metrics_ the `ServiceMonitor` customisation is now set via `kube-state-metrics.prometheus.monitor` and the `kubeStateMetrics.serviceMonitor.selfMonitor.enabled` value has moved to `kube-state-metrics.selfMonitor.enabled`.

For _prometheus-node-exporter_ the `ServiceMonitor` customisation is now set via `prometheus-node-exporter.prometheus.monitor` and the `nodeExporter.jobLabel` values has moved to `prometheus-node-exporter.prometheus.monitor.jobLabel`.

## From 22.x to 23.x

Port names have been renamed for Istio's
[explicit protocol selection](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/#explicit-protocol-selection).

| | old value | new value |
|-|-----------|-----------|
| `alertmanager.alertmanagerSpec.portName` | `web` | `http-web` |
| `grafana.service.portName` | `service` | `http-web` |
| `prometheus-node-exporter.service.portName` | `metrics` (hardcoded) | `http-metrics` |
| `prometheus.prometheusSpec.portName` | `web` | `http-web` |

## From 21.x to 22.x

Due to the upgrade of the `kube-state-metrics` chart, removal of its deployment/stateful needs to done manually prior to upgrading:

```console
kubectl delete deployments.apps -l app.kubernetes.io/instance=prometheus-operator,app.kubernetes.io/name=kube-state-metrics --cascade=orphan
```

or if you use autosharding:

```console
kubectl delete statefulsets.apps -l app.kubernetes.io/instance=prometheus-operator,app.kubernetes.io/name=kube-state-metrics --cascade=orphan
```

## From 20.x to 21.x

The config reloader values have been refactored. All the values have been moved to the key `prometheusConfigReloader` and the limits and requests can now be set separately.

## From 19.x to 20.x

Version 20 upgrades prometheus-operator from 0.50.x to 0.52.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRDs manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.52.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 18.x to 19.x

`kubeStateMetrics.serviceMonitor.namespaceOverride` was removed.
Please use `kube-state-metrics.namespaceOverride` instead.

## From 17.x to 18.x

Version 18 upgrades prometheus-operator from 0.49.x to 0.50.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRDs manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 16.x to 17.x

Version 17 upgrades prometheus-operator from 0.48.x to 0.49.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRDs manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.49.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 15.x to 16.x

Version 16 upgrades kube-state-metrics to v2.0.0. This includes changed command-line arguments and removed metrics, see this [blog post](https://kubernetes.io/blog/2021/04/13/kube-state-metrics-v-2-0/). This version also removes Grafana dashboards that supported Kubernetes 1.14 or earlier.

## From 14.x to 15.x

Version 15 upgrades prometheus-operator from 0.46.x to 0.47.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRDs manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.47.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 13.x to 14.x

Version 14 upgrades prometheus-operator from 0.45.x to 0.46.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRDs manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.46.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

## From 12.x to 13.x

Version 13 upgrades prometheus-operator from 0.44.x to 0.45.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRD manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.45.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.45.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.45.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
```

## From 11.x to 12.x

Version 12 upgrades prometheus-operator from 0.43.x to 0.44.x. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRD manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.44/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
```

The chart was migrated to support only helm v3 and later.

## From 10.x to 11.x

Version 11 upgrades prometheus-operator from 0.42.x to 0.43.x. Starting with 0.43.x an additional `AlertmanagerConfigs` CRD is introduced. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRD manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
```

Version 11 removes the deprecated tlsProxy via ghostunnel in favor of native TLS support the prometheus-operator gained with v0.39.0.

## From 9.x to 10.x

Version 10 upgrades prometheus-operator from 0.38.x to 0.42.x. Starting with 0.40.x an additional `Probes` CRD is introduced. Helm does not automatically upgrade or install new CRDs on a chart upgrade, so you have to install the CRD manually before updating:

```console
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.42/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
```

## From 8.x to 9.x

Version 9 of the helm chart removes the existing `additionalScrapeConfigsExternal` in favour of `additionalScrapeConfigsSecret`. This change lets users specify the secret name and secret key to use for the additional scrape configuration of prometheus. This is useful for users that have prometheus-operator as a subchart and also have a template that creates the additional scrape configuration.

## From 7.x to 8.x

Due to new template functions being used in the rules in version 8.x.x of the chart, an upgrade to Prometheus Operator and Prometheus is necessary in order to support them. First, upgrade to the latest version of 7.x.x

```console
helm upgrade [RELEASE_NAME] prometheus-community/kube-prometheus-stack --version 7.5.0
```

Then upgrade to 8.x.x

```console
helm upgrade [RELEASE_NAME] prometheus-community/kube-prometheus-stack --version [8.x.x]
```

Minimal recommended Prometheus version for this chart release is `2.12.x`

## From 6.x to 7.x

Due to a change in grafana subchart, version 7.x.x now requires Helm >= 2.12.0.

## From 5.x to 6.x

Due to a change in deployment labels of kube-state-metrics, the upgrade requires `helm upgrade --force` in order to re-create the deployment. If this is not done an error will occur indicating that the deployment cannot be modified:

```console
invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app.kubernetes.io/name":"kube-state-metrics"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
```

If this error has already been encountered, a `helm history` command can be used to determine which release has worked, then `helm rollback` to the release, then `helm upgrade --force` to this new one
