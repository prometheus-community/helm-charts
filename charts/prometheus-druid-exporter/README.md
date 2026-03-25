# Prometheus Druid Exporter

A Prometheus exporter for [Druid](https://druid.apache.org/) metrics.

Installs the [Druid Exporter](https://github.com/opstree/druid-exporter) for [Prometheus](https://prometheus.io/).

Some of the metrics collections are:-

- Druid's health metrics
- Druid's datasource metrics
- Druid's segment metrics
- Druid's supervisor metrics
- Druid's tasks metrics
- Druid's components metrics like:- broker, historical, ingestion(kafka), coordinator, sys

## Prerequisites

- Kubernetes 1.16+
- Helm 3.7+

Helm v2 was no longer supported from chart version 1.0.0.

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-druid-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-druid-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-druid-exporter
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

#### To 1.0.0

Helm v2 was no longer supported from chart version 1.0.0.

_See [Migrating Helm v2 to v3](https://helm.sh/docs/topics/v2_v3_migration/) guide._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-druid-exporter/values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-druid-exporter
```

### Druid Server Connection

To use this chart, ensure that `druidURL` is populated with valid Druid URL. Basically this is the URL of druid router or coordinator service.

An example could be:-

```console
http://druid.opstreelabs.in
```

### Service Monitor

The chart comes with a ServiceMonitor for use with the [kube-pometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack). If you're not using the Prometheus Operator, you can disable the ServiceMonitor by setting `serviceMonitor.enabled` to `false` and it will auto generate the following `podAnnotations` into deployment.yaml:

```yaml
podAnnotations:
  prometheus.io/path: /metrics
  prometheus.io/port: metrics
  prometheus.io/scrape: "true"
```
