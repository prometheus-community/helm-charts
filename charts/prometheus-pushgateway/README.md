# Prometheus Pushgateway

This chart bootstraps a prometheus [pushgateway](http://github.com/prometheus/pushgateway) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

An optional prometheus `ServiceMonitor` can be enabled, should you wish to use this gateway with a [Prometheus Operator](https://github.com/coreos/prometheus-operator).

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-pushgateway
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

### To 2.0.0

Chart API version has been upgraded to v2 so Helm 3 is needed from now on.

Docker image tag is used from Chart.yaml appVersion field by default now.

Version 2.0.0 also adapted [Helm label and annotation best practices](https://helm.sh/docs/chart_best_practices/labels/). Specifically, labels mapping is listed below:

```console
OLD                 => NEW
----------------------------------------
heritage            => app.kubernetes.io/managed-by
chart               => helm.sh/chart
[container version] => app.kubernetes.io/version
app                 => app.kubernetes.io/name
release             => app.kubernetes.io/instance
```

Therefore, depending on the way you've configured the chart, the previous StatefulSet or Deployment need to be deleted before upgrade.

If `runAsStatefulSet: false` (this is the default):

```console
kubectl delete deploy -l app=prometheus-pushgateway
```

If `runAsStatefulSet: true`:

```console
kubectl delete sts -l app=prometheus-pushgateway
```

After that do the actual upgrade:

```console
helm upgrade -i prometheus-pushgateway prometheus-community/prometheus-pushgateway
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-pushgateway
```
