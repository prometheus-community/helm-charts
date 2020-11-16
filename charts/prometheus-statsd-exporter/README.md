# prometheus-statsd-exporter

The [prometheus-statsd-exporter](https://github.com/prometheus/statsd_exporter) receives StatsD metrics and exports them as Prometheus metrics.

This chart creates a `prometheus-statsd-exporter` deployment using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.16 or above

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
help repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-statsd-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-statsd-exporter
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Test Chart

```sh
helm test prometheus-statsd-exporter
```

_See [helm test](https://helm.sh/docs/helm/helm_test/) for command documentation._

## Uninstall Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
$ helm delete --purge [RELEASE_NAME]
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

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values prometheus-community/prometheus-statsd-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-statsd-exporter
```

## Metric Mapping and Configuration
This chart provides a minimal default configuration. To create a custom mapping configuration and review default settings, consult the [official docs](https://github.com/prometheus/statsd_exporter#metric-mapping-and-configuration).
