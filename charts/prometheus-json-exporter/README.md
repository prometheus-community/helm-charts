# prometheus-json-exporter

Prometheus exporter for scraping JSON by JSONPath.

This chart bootstraps a [json_exporter](https://github.com/prometheus-community/json_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.10+ with Beta APIs enabled
- Helm 3+

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-json-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-json-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-json-exporter
```

_See [configuration](## Configuring) below._

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

#### From 0.7.x to 0.8.0

This version fixes configmap name according to the chart standard so that configmap will be recreated with subsequent deployment rollout.
See [#3926](https://github.com/prometheus-community/helm-charts/pull/3926) for more context.

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-json-exporter
```

For more information please refer to the [json_exporter](https://github.com/prometheus-community/json_exporter) documentation.
