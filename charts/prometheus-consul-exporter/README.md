# Prometheus Consul Exporter

A Prometheus exporter for [Consul](https://www.consul.io/) metrics.

This chart creates a [Consul Exporter](https://github.com/prometheus/consul_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.25+ with Beta APIs enabled
- Helm 3

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-consul-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-consul-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-consul-exporter
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

#### From 1.1.1 to 2.0.0

support for PSP was removed, as a result support for older k8s version where those resources are needed is dropped as well
This version supports k8s version 1.25+

#### From 0.5.x to 1.0.0

Helm `apiVersion` has been increased to `v2` in version 1.0.0. As a result, Helm v3 is required to install the chart. Please, see notes on [migration from Helm v2 to Helm v3](https://helm.sh/docs/topics/v2_v3_migration/).

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-consul-exporter
```

### Consul Server Info

Set `consulServer` to `[MY_CONSUL_HOST]:[MY_CONSUL_PORT]`.

### Flags

Check the [Flags](https://github.com/prometheus/consul_exporter#flags) list and add to the `options` block in your value overrides.
