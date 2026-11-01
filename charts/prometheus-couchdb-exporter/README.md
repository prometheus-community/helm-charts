# prometheus-couchdb-exporter

A Prometheus exporter for [CouchDB](https://couchdb.apache.org/) metrics.

This chart bootstraps a [CouchDB Exporter](https://github.com/gesellix/couchdb-prometheus-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Helm 3.7+

Helm v2 was no longer supported from chart version 1.0.0.

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-couchdb-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-couchdb-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-couchdb-exporter
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

#### To 1.0.0

Helm v2 was no longer supported from chart version 1.0.0.

_See [Migrating Helm v2 to v3](https://helm.sh/docs/topics/v2_v3_migration/) guide._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-couchdb-exporter
```
