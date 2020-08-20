# Prometheus MongoDB Exporter

A Prometheus exporter for [MongoDB](https://www.mongodb.com/) metrics.

Installs the [MongoDB Exporter](https://github.com/percona/mongodb_exporter) for [Prometheus](https://prometheus.io/). The
MongoDB Exporter collects and exports oplog, replica set, server status, sharding and storage engine metrics.

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-mongodb-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-mongodb-exporter
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

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values prometheus-community/prometheus-mongodb-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-mongodb-exporter
```

### MongoDB Server Connection

To use the chart, ensure the `mongodb.uri` is populated with a valid [MongoDB URI](https://docs.mongodb.com/manual/reference/connection-string) or an existing secret (in the releases namespace) containing the key defined on `existingSecret.key`, with the URI is referred via `existingSecret.name`. If no secret key is defined, the default value is `mongodb-uri`.

If the MongoDB server requires authentication, credentials should be populated in the connection string as well. The MongoDB Exporter supports connecting to either a MongoDB replica set member, shard, or standalone instance.

### Service Monitor

The chart comes with a ServiceMonitor for use with the [Prometheus Operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator). If you're not using the Prometheus Operator, you can disable the ServiceMonitor by setting `serviceMonitor.enabled` to `false` and instead populate the `podAnnotations` as below:

```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "metrics"
```
