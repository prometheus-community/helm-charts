# Prometheus Fastly Exporter

A Prometheus exporter for [Fastly](https://fastly.com/) metrics.

This chart creates a [Fastly Exporter](https://github.com/fastly/fastly-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-fastly-exporter
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
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### Fastly token

To use the chart, ensure the `fastly.token` is populated with a valid [Fastly API token](https://docs.fastly.com/guides/account-management-and-security/using-api-tokens#creating-api-tokens) or an existing secret (in the releases namespace) containing the key defined on `existingSecret.key`, with the token is referred via `existingSecret.name`. If no secret key is defined, the default value is `fastly-api-token`.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-fastly-exporter
```

### Flags

Check the filtering [Flags](https://github.com/fastly/fastly-exporter#filtering-services) list and add to the `options` block in your value overrides.
