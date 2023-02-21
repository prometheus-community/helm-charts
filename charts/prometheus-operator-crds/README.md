# Prometheus Operator CRDs

This chart brings Custom Resource Definitions (CRD) used by Prometheus Operator introducing the API group `monitoring.coreos.com`. The Prometheus Operator uses Kubernetes custom resources to simplify the deployment and configuration of Prometheus, Alertmanager and related monitoring components.

For more information on Prometheus Operator and CRDs, please, see [documentation](https://prometheus-operator.dev/docs/operator/design/).

## Prerequisites

- Kubernetes >= 1.16.0
- Helm 3

## Get Repository Info
<!-- textlint-disable terminology -->
```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._
<!-- textlint-enable -->

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-operator-crds
```

_See [configuration](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release
_including_ resources of Kind `Prometheus`, `Alertmanager`, `ServiceMonitor`, etc.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-operator-crds
```
