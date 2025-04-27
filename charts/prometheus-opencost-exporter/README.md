# Prometheus Opencost Exporter

Prometheus exporter for [OpenCost](https://www.opencost.io) Kubernetes cost monitoring data.

This chart bootstraps a Prometheus [OpenCost exporter](https://www.opencost.io/docs/integrations/opencost-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

The original source for this Helm chart is <https://github.com/opencost/opencost-helm-chart>.

## **Deprecated**

**This chart is deprecated in favor of the the [upstream support](https://opencost.io/docs/installation/prometheus/). The chart source code will be removed in 1st Jun 2025.**

## Prerequisites

- Kubernetes 1.23+
- Helm 3+

## Add Helm Chart Repository

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-opencost-exporter
```

_See [configuration](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Other minor version upgrade

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-opencost-exporter
```
