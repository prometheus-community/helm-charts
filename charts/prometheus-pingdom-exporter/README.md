# Prometheus Pingdom Exporter

- **Source:** <https://github.com/kokuwaio/pingdom-exporter>

The [prometheus-pingdom-exporter](https://github.com/kokuwaio/pingdom-exporter) processes [Pingdom](https://www.pingdom.com/) uptime check results for consumption by Prometheus.

## Prerequisites

- Kubernetes 1.16+

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm install`](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-pingdom-exporter
```

```markdown
_See [configuration](#configuration) below._
```

_See [`helm install`](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [`helm uninstall`](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To version 3.0.0

The docker image has been change too <ghcr.io/monotek/pingdom-exporter>.

The config uses `pingdom.apiToken` only which is used as env var.

The docker port changed to `9158`.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-pingdom-exporter
```
