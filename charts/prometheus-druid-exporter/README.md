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

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-druid-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-druid-exporter
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
# helm delete --purge [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
# Helm 3 or 2
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-druid-exporter/values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values prometheus-community/prometheus-druid-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-druid-exporter
```

### Druid Server Connection

To use this chart, ensure that `druidURL` is populated with valid Druid URL. Basically this is the URL of druid router or coordinator service.

An example could be:-

```console
http://druid.opstreelabs.in
```

### Service Monitor

The chart comes with a ServiceMonitor for use with the [kube-pometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack). If you're not using the Prometheus Operator, you can disable the ServiceMonitor by setting `serviceMonitor.enabled` to `false` and instead populate the `podAnnotations` as below:

```yaml
podAnnotations:
  prometheus.io/path: /metrics
  prometheus.io/port: metrics
  prometheus.io/scrape: "true"
```
