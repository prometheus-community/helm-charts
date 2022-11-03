# prometheus-to-sd

[prometheus-to-sd](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd) is a simple component that can scrape metrics stored in prometheus text format from one or multiple components and push them to the Stackdriver

## Prerequisites

- a service exposing metrics in prometheus format
- k8s cluster should run on GCE or GKE

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

<!-- textlint-disable terminology -->
_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._
<!-- textlint-enable -->

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-to-sd
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
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
helm show values prometheus-community/prometheus-to-sd
```

For more information please refer to the [prometheus-to-sd](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd) documentation.

### Metrics Sources

Multiple metrics sources can be defined. To configure, set `metricsSources` value (example: `http://kube-state-metrics:8080`)
