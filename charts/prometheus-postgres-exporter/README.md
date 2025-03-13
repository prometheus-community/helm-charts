# Prometheus Postgres Exporter

Prometheus exporter for [PostgreSQL](https://www.postgresql.org/about/servers/) server metrics.

This chart bootstraps a Prometheus [Postgres exporter](https://github.com/prometheus-community/postgres_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+

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
helm install [RELEASE_NAME] prometheus-community/prometheus-postgres-exporter
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
helm upgrade [RELEASE_NAME] prometheus-community/prometheus-postgres-exporter --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 6.0.0

Image repository has been split into two values: the new `image.registry` value and the already existing `image.repository` value. No change is required when using the default for `image.repository`. If you have previously modified field `image.repository`, please, set the two fields accordingly.

### To 5.0.0

Deprecated options `auto-discover-databases`, `constantLabels`, `exclude-databases` & `include-databases` has been removed.
Deprecated custom query config has been removed.
Deprecated PodSecurityPolicy and K8S beta API versions have been removed.
Chart.yaml appVersion field is used as default image tag.
Labels are templated now.
Add default securityContext and PodSecurityContext.
LivenessProbe timeout has been raised to 3.

### To 4.6.0

This release adds functionality to template the variables inside `config.datasource` by means of allowing the `tpl` function in the resources that make use of it. This functionality is useful when you want to do sub-charting (e.g. in a postgres chart) and you want to avoid the duplication of variables inside `config.datasource`.

Compared to the previous release (4.5.0) the only thing that changed is the fact that you can no longer leave the `config.datasource.host` variable blank. Leaving it blank could cause errors with the `tpl` function. However, the default value was changed to `''` so this error is not expected to happen.

### To 4.0.0

This release removes the `pg_database` query from `config.queries` as it has been converted to a built-in collector
in postgres_exporter v0.11.0. Any customizations to the removed query are now rendered useless and thus should be removed.

### To 3.0.0

This release introduces changes to accommodate Postgres 13 or newer versions by default.
Older Postgres instances have now to overwrite the `pg_stat_statements` query of `config.queries` with following
selection:

```postgresql
SELECT t2.rolname,
       t3.datname,
       queryid,
       calls,
       total_time / 1000     as total_time_seconds,
       min_time / 1000       as min_time_seconds,
       max_time / 1000       as max_time_seconds,
       mean_time / 1000      as mean_time_seconds,
       stddev_time / 1000    as stddev_time_seconds,
       rows,
       shared_blks_hit,
       shared_blks_read,
       shared_blks_dirtied,
       shared_blks_written,
       local_blks_hit,
       local_blks_read,
       local_blks_dirtied,
       local_blks_written,
       temp_blks_read,
       temp_blks_written,
       blk_read_time / 1000  as blk_read_time_seconds,
       blk_write_time / 1000 as blk_write_time_seconds
FROM pg_stat_statements t1
         JOIN pg_roles t2 ON (t1.userid = t2.oid)
         JOIN pg_database t3 ON (t1.dbid = t3.oid)
WHERE t2.rolname != 'rdsadmin'
  AND queryid IS NOT NULL `
```

### To 2.0.0

The primary change in 2.0.0 is the Chart API from v1 to v2. This now requires Helm3.
Backwards compatibility is not guaranteed unless you modify the labels used on the chart's deployments.
Use the workaround below to upgrade from versions previous to 2.0.0. The following example assumes that the release name
is prometheus-postgres-exporter:

```console
kubectl patch deployment prometheus-postgres-exporter --type=json -p='[{"op": "remove", "path": "/spec/selector/matchLabels/chart"}]'
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).
To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run this command:

```console
helm show values prometheus-community/prometheus-postgres-exporter
```
