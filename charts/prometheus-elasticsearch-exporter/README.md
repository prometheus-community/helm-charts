# Elasticsearch Exporter

Prometheus exporter for various metrics about ElasticSearch, written in Go.

Learn more: <https://github.com/prometheus-community/elasticsearch_exporter>

This chart creates an Elasticsearch-Exporter deployment on a [Kubernetes](http://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.10+

## Get Helm Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Helm Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-elasticsearch-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-elasticsearch-exporter
```

The command deploys Elasticsearch Exporter on the Kubernetes cluster using the default configuration.

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Helm Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
# helm delete --purge [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Helm Chart

```console
# Helm 3 or 2
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 5.0.0

`securityContext` has been renamed to `podSecurityContext` and `securityContext.enabled` has no effect anymore. To mirror the behaviour of `securityContext.enabled=false` of 4.x unset `podSecurityContext`.

```console
helm install --set podSecurityContext=null my-exporter stable/elasticsearch-exporter
```

In 5.0.0 `securityContext` refers to the container's securityContext instead which was not configurable in earlier versions. The naming is aligned with the base charts created by Helm.

Default values for `podSecurityContext` and `securityContext` have been updated to be compatible with the Pod Security Standard level "restricted". Most notably `seccompProfile.type` is set to `RuntimeDefault`.

### To 4.0.0

While migrating the chart from `stable/elasticsearch-exporter` it was renamed to `prometheus-elasticsearch-exporter`.
If you want to upgrade from a previous version and you need to keep the old resource names (`Service`, `Deployment`, etc) you can set `fullnameOverride` and `nameOverride` to do so.

The example below shows how those values should be set for a `my-exporter` release of the previous chart.

```console
helm install my-exporter stable/elasticsearch-exporter
helm upgrade my-exporter . --set fullnameOverride=my-exporter-elasticsearch-exporter --set nameOverride=elasticsearch-exporter
```

### To 3.0.0

`prometheusRule.rules` are now processed as Helm template, allowing to set variables in them.
This means that if a rule contains a {{ $value }}, Helm will try replacing it and probably fail.

You now need to escape the rules (see `values.yaml`) for examples.

### To 2.0.0

Some Kubernetes APIs used from 1.x have been deprecated. You need to update your cluster to Kubernetes 1.10+ to support new definitions used in 2.x.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).
To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values prometheus-community/prometheus-elasticsearch-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-elasticsearch-exporter
```

> **Tip**: You can use the default [values.yaml](values.yaml)
