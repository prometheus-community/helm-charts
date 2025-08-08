# Prometheus NATS Exporter

An Prometheus Exporter for [NATS](https://github.com/nats-io/k8s) metrics.

This chart bootstraps a prometheus [NATS Exporter](https://github.com/nats-io/prometheus-nats-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-nats-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-nats-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-nats-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-nats-exporter
```

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
# helm delete --purge [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
# Helm 3 or 2
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values oci://ghcr.io/prometheus-community/charts/prometheus-nats-exporter

# Helm 3
$ helm show values oci://ghcr.io/prometheus-community/charts/prometheus-nats-exporter
```
