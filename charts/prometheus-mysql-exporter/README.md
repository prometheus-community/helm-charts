# Prometheus Mysql Exporter

A Prometheus exporter for [MySQL](https://www.mysql.com/) metrics.

This chart bootstraps a Prometheus [MySQL Exporter](http://github.com/prometheus/mysql_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-mysql-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-mysql-exporter
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
$ helm inspect values prometheus-community/prometheus-mysql-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-mysql-exporter
```

### MySQL Connection

The exporter can connect to mysql directly or using the [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy).

- To configure direct MySQL connection by value, set `mysql.user`, `mysql.pass`, `mysql.host` and `mysql.port` (see additional options in the `mysql` configuration block)
- To configure direct MySQL connnetion by secret, you must store a connection string in a secret, and set `mysql.existingSecret` to `[SECRET_NAME]`

### Exporter Documentation and Params

Documentation for the MySQL Exporter can be found here: (<https://github.com/prometheus/mysqld_exporter>)
A mysql params overview can be found here: (<https://github.com/go-sql-driver/mysql#dsn-data-source-name>)

### Collector Flags

Available collector flags can be found in the [values.yaml](https://github.com/kilhyunjun/charts/blob/master/stable/prometheus-mysql-exporter/values.yaml) and a description of each flag can be found in the [mysqld_exporter](https://github.com/prometheus/mysqld_exporter#collector-flags) repository.
