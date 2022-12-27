# Prometheus `Node Exporter`

Prometheus exporter for hardware and OS metrics exposed by *NIX kernels, written in Go with pluggable metric collectors.

This chart bootstraps a prometheus [`Node Exporter`](http://github.com/prometheus/node_exporter) daemonset on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-node-exporter
```

_See [configuration](#configuring) below._

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

### 4.8.x to 4.9.0

Release 4.9.0 is introducing a [PodMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#podmonitor) that can now be defined through the values file giving thus, next to a [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#servicemonitor), another option to have Prometheus configured by Prometheus operator for scraping Node Exporter containers. Using a PodMonitor may be preferred in some environments where there is very large number of Node Exporter endpoints (1000+) behind a single service.

The PodMonitor is disabled by default. When switching from ServiceMonitor to PodMonitor, the time series resulting from the configuration through PodMonitor may have different labels. For instance, there will not be the `service` label any longer which might affect PromQL queries selecting that label.

### 3.x to 4.x

Starting from version 4.0.0, the `node exporter` chart is using the [Kubernetes recommended labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/). Therefore you have to delete the daemonset before you upgrade.

```console
kubectl delete daemonset -l app=prometheus-node-exporter
helm upgrade -i prometheus-node-exporter prometheus-community/prometheus-node-exporter
```

If you use your own custom [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#servicemonitor) or [PodMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#podmonitor), please ensure to upgrade their `selector` fields accordingly to the new labels.

### From 2.x to 3.x

Change the following:

```yaml
hostRootFsMount: true
```

to:

```yaml
hostRootFsMount:
  enabled: true
  mountPropagation: HostToContainer
```

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-node-exporter
```
