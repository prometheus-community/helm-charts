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
helm install [RELEASE_NAME] prometheus-community/prometheus-operator-admission-webhook
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
helm upgrade [RELEASE_NAME] prometheus-community/prometheus-operator-admission-webhook --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-operator-admission-webhook
```
