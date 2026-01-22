# Prometheus Pingdom Exporter

- **Source:** <https://github.com/kokuwaio/pingdom-exporter>

The [prometheus-pingdom-exporter](https://github.com/kokuwaio/pingdom-exporter) processes [Pingdom](https://www.pingdom.com/) uptime check results for consumption by Prometheus.

## Prerequisites

- Kubernetes 1.16+

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-pingdom-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-pingdom-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-pingdom-exporter
```

```markdown
_See [configuration](#configuration) below._
```

_See [`helm install`](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [`helm uninstall`](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

#### To version 3.0.0

The Docker image has been change too <ghcr.io/monotek/pingdom-exporter>.

The config uses `pingdom.apiToken` only which is used as env var.

The Docker port changed to `9158`.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-pingdom-exporter
```
