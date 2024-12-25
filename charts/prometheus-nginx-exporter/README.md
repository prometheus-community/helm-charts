# NGINX Prometheus Exporter

This chart bootstraps a [NGINX Prometheus Exporter](https://github.com/nginxinc/nginx-prometheus-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+ with Beta APIs enabled
- Helm 3

## Get Repository Info
<!-- textlint-disable terminology -->
```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._
<!-- textlint-enable -->
## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-nginx-exporter
```

_See [configuration](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] prometheus-community/prometheus-nginx-exporter --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 1.0

Chart release 1.0 reflects a major bump of the default NGINX Exporter image tag from major number 0 to 1.

This release has switched to using flags in the new format (`--flag`) but still supports the
deprecated format (`-flag`) transparently for NGINX Exporter below release 1.0.0.

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-nginx-exporter
```
