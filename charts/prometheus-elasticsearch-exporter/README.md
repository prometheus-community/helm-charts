# Prometheus Elasticsearch Exporter

Prometheus exporter for various metrics about Elasticsearch, written in Go. For more information, please, see the project's [repository](https://github.com/prometheus-community/elasticsearch_exporter).

This chart creates an Elasticsearch exporter deployment on a [Kubernetes](http://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Helm 3.7+
- Kubernetes 1.19+

## Get Helm Repository Info
<!-- textlint-disable terminology -->
```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._
<!-- textlint-enable -->
## Install Helm Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-elasticsearch-exporter
```

The command deploys Elasticsearch Exporter on the Kubernetes cluster using the default configuration.

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Helm Chart

```console
helm upgrade [RELEASE_NAME] prometheus-community/prometheus-elasticsearch-exporter --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## To 6.0.0

In release 6.0, the chart API version has been increased to v2. From now on, the chart supports Helm 3 only.

The minimum Kubernetes version supported by the chart has been raised to 1.19.

Labels and selectors have been replaced following [Helm 3 label and annotation best practices](https://helmsh/docs/chart_best_practices/labels/):

| Previous            | Current                      |
|---------------------|------------------------------|
| app                 | app.kubernetes.io/name       |
| chart               | helm.sh/chart                |
| [none]              | app.kubernetes.io/version    |
| heritage            | app.kubernetes.io/managed-by |
| release             | app.kubernetes.io/instance   |

As the change is affecting immutable selector labels, the deployment must be deleted before upgrading the release, e.g.:

```console
kubectl delete deploy -l app=prometheus-elasticsearch-exporter
```

Once the resources have been deleted, you can upgrade the release:

```console
helm upgrade -i RELEASE_NAME prometheus-community/prometheus-elasticsearch-exporter
```

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
helm show values prometheus-community/prometheus-elasticsearch-exporter
```

> **Tip**: You can use the default [values.yaml](values.yaml)
