# Prometheus Operator Admission Webhook

> The admission webhook service is able to
>
> - Validate requests ensuring that PrometheusRule and AlertmanagerConfig objects are semantically valid
> - Mutate requests enforcing that all annotations of PrometheusRule objects are coerced into string values
> - Convert AlertmanagerConfig objects between v1alpha1 and v1beta1 versions

For more info, please, see the [Prometheus Operator](https://prometheus-operator.dev/docs) documentation.

## Prerequisites

- Kubernetes 1.13+ with Beta APIs enabled
- Helm 3

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-operator-admission-webhook`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-operator-admission-webhook`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-operator-admission-webhook
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
helm upgrade [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-operator-admission-webhook --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-operator-admission-webhook
```
