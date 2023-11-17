# prometheus-json-exporter

Prometheus exporter for scraping JSON by JSONPath.

This chart bootstraps a [json_exporter](https://github.com/prometheus-community/json_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.10+ with Beta APIs enabled
- Helm 3+

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
```

<!-- textlint-disable -->
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._
<!-- textlint-enable -->

## Install Chart

```console
# Helm
$ helm install [RELEASE_NAME] prometheus-community/prometheus-json-exporter
```

_See [configuration](## Configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
# Helm
$ helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
# Helm
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

### From 0.7.x to 0.8.0

This version fixes configmap name according to the chart standard so that configmap will be recreated with subsequent deployment rollout.
See [#3926](https://github.com/prometheus-community/helm-charts/pull/3926) for more context.

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm
$ helm show values prometheus-community/prometheus-json-exporter
```

For more information please refer to the [json_exporter](https://github.com/prometheus-community/json_exporter) documentation.
