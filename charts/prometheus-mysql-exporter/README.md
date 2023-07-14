# Prometheus Mysql Exporter

A Prometheus exporter for [MySQL](https://www.mysql.com/) metrics.

This chart bootstraps a Prometheus [MySQL Exporter](https://github.com/prometheus/mysqld_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Get Helm Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-mysql-exporter
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

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

### From 1.x to 2.x

mysqld_exporter has been updated to [v0.15.0](https://github.com/prometheus/mysqld_exporter/releases/tag/v0.15.0), removing support for `DATA_SOURCE_NAME`. Configuration for exporter use `--config.my-cnf` with a custom cnf file (secret).

If you use `mysql.existingSecret` to set full `DATA_SOURCE_NAME`, please set `mysql.existingConfigSecret.name` & `mysql.existingConfigSecret.key` to reference the secret config.

```yaml
mysql:
  existingSecret: "my-data-source"
```

to:

```yaml
mysql:
  existingConfigSecret:
    name: "config"
    key: "my.cnf"
```

If you use `mysql.param` to extend `DATA_SOURCE_NAME`, please set `mysql.additionalConfig` with extra params to extend my.cnf file.

```yaml
mysql:
  param: "debug&connect-timeout=5"
```

to:

```yaml
mysql:
  additionalConfig:
    - connect-timeout=5
    - debug
```

This version uses [cloud-sql-proxy v2](https://github.com/GoogleCloudPlatform/cloud-sql-proxy/blob/main/migration-guide.md).

If you use `cloudsqlproxy.ipAddressTypes` to set private connections, please set `cloudsqlproxy.privateIp`.

```yaml
cloudsqlproxy:
  ipAddressTypes: PRIVATE,PUBLIC
```

to:

```yaml
cloudsqlproxy:
  privateIp: true
```

### To =< 1.0.0

Version 1.0.0 is a major update.

- The chart now follows the new Kubernetes label recommendations:
<https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/>

The simplest way to update is to do a force upgrade, which recreates the resources by doing a delete and an install.

```console
helm upgrade prometheus-mysql-exporter prometheus-community/prometheus-mysql-exporter --force
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-mysql-exporter/values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-mysql-exporter
```

### MySQL Connection

The exporter can connect to mysql directly or using the [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy).

- To configure direct MySQL connection by value, set `mysql.user`, `mysql.pass`, `mysql.host` and `mysql.port` (see additional options in the `mysql` configuration block)
- To configure direct MySQL connection by secret, you must store a connection string in a secret, and set `mysql.existingSecret` to `[SECRET_NAME]`

### Exporter Documentation and Params

Documentation for the MySQL Exporter can be found here: (<https://github.com/prometheus/mysqld_exporter>)
A mysql params overview can be found here: (<https://github.com/go-sql-driver/mysql#dsn-data-source-name>)

### Collector Flags

Available collector flags can be found in the [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-mysql-exporter/values.yaml) and a description of each flag can be found in the [mysqld_exporter](https://github.com/prometheus/mysqld_exporter#collector-flags) repository.

### CloudSql Proxy Workload Identity

Enable it with flag  [`cloudsqlproxy.workloadIdentity`](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-mysql-exporter/values.yaml)
To more details about Workload Identity visit [Use Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
