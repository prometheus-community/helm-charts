# yet-another-cloudwatch-exporter

YACE, or `yet another cloudwatch exporter`, is a Prometheus exporter for AWS CloudWatch metrics.

This chart bootstraps a [YACE](https://github.com/prometheus-community/yet-another-cloudwatch-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Get Helm Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-yet-another-cloudwatch-exporter
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-yet-another-cloudwatch-exporter
```

## Migrate from nerdswords/helm-charts (before version 0.39.0)

If you are migrate from the [`nerdswords/helm-charts` repository](https://github.com/nerdswords/helm-charts/tree/main/charts/yet-another-cloudwatch-exporter), you must consider the following changes:

* the chart name has changed from `yet-another-cloudwatch-exporter` to `prometheus-yet-another-cloudwatch-exporter`.
* to avoid conflicts with the new chart name, you can set the `nameOverride` value to `yet-another-cloudwatch-exporter` in your `values.yaml` file.
