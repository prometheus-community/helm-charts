# Prometheus Pushgateway

This chart bootstraps a prometheus [pushgateway](http://github.com/prometheus/pushgateway) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

An optional prometheus `ServiceMonitor` can be enabled, should you wish to use this gateway with a [Prometheus Operator](https://github.com/coreos/prometheus-operator).

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repository](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-pushgateway

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-pushgateway
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
# helm delete --purge [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
# Helm 3 or 2
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 2.0.0

__!!! BREAKING CHANGE !!!__

Version 2.0.0 adapted [Helm label and annotation best practices](https://helm.sh/docs/chart_best_practices/labels/). Specifically, labels mapping is listed below:

```console
OLD                 => NEW
----------------------------------------
heritage            => app.kubernetes.io/managed-by
chart               => helm.sh/chart
[container version] => app.kubernetes.io/version
app                 => app.kubernetes.io/name
release             => app.kubernetes.io/instance
```

Because select labels are immutable, `helm upgrade` cannot be supported. Please reivew and save the existing labels and adapt to the new labels. Then, [uninstall](#markdown-header-uninstall-chart) and [reinstall](#markdown-header-install-chart) the new chart.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values prometheus-community/prometheus-pushgateway

# Helm 3
$ helm show values prometheus-community/prometheus-pushgateway
```
