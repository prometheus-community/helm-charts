# prometheus-redis-exporter

Prometheus exporter for [Redis](https://redis.io/) metrics.

This chart bootstraps a [Redis exporter](https://github.com/oliver006/redis_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.10+ with Beta APIs enabled
- Helm 3+

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-redis-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-redis-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-redis-exporter
```

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

#### To 5.0.0

From 5.0.0 redis exporter is using the [Kubernetes recommended labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/). Therefore you have to delete the deployment before you upgrade.

```console
kubectl delete deployment -l app=prometheus-redis-exporter
helm upgrade -i prometheus-redis-exporter prometheus-community/prometheus-redis-exporter
```

From 5.0.0 redis exporter helm chart supports multiple targets.

By enabling `serviceMonitor.multipleTarget` and settings the targets in `serviceMonitor.targets`, multiple redis instance can be scraped.

```yaml
serviceMonitor:
  enabled: true
  multipleTarget: true
  telemetryPath: /scrape
  targets:
  - url: redis://my-redis:6379
    name: foo
  - url: redis://my-redis-cluster:6379
    name: bar
    additionalRelabeling:
    - sourceLabels: [type]
      targetLabel: type
      replacement: cluster
```

#### To 3.0.1

 The default tag for the exporter image is now `v1.x.x`. This major release includes changes to the names of various metrics and no longer directly supports the configuration (and scraping) of multiple redis instances; that is now the Prometheus server's responsibility. You'll want to use [this dashboard](https://github.com/oliver006/redis_exporter/blob/master/contrib/grafana_prometheus_redis_dashboard.json) now. Please see the [redis_exporter GitHub page](https://github.com/oliver006/redis_exporter#upgrading-from-0x-to-1x) for more details.

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-redis-exporter
```

For more information please refer to the [redis_exporter](https://github.com/oliver006/redis_exporter) documentation.

### Redis Connection

- To configure Redis connection by value set `redisAddress` string (example format: `redis://myredis:6379`)
- To configure Redis connection by configmap set `redisAddressConfig.enabled` to `true`, set `redisAddressConfig.configmap.name` and `redisAddressConfig.configmap.key` values
- To configure auth by value, set `auth.enabled` to `true`, and `auth.redisPassword` value
- To configure auth by secret, set `auth.secret.name` and `auth.secret.key` values

### Using a custom LUA-Script

First, you need to deploy the script with a configmap. This is an example script from mentioned in the [redis_exporter-image repository](https://github.com/oliver006/redis_exporter/blob/master/contrib/sample_collect_script.lua)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-redis-exporter-script
data:
  script: |-
    -- Example collect script for -script option
    -- This returns a Lua table with alternating keys and values.
    -- Both keys and values must be strings, similar to a HGETALL result.
    -- More info about Redis Lua scripting: https://redis.io/commands/eval

    local result = {}

    -- Add all keys and values from some hash in db 5
    redis.call("SELECT", 5)
    local r = redis.call("HGETALL", "some-hash-with-stats")
    if r ~= nil then
        for _,v in ipairs(r) do
            table.insert(result, v) -- alternating keys and values
        end
    end

    -- Set foo to 42
    table.insert(result, "foo")
    table.insert(result, "42") -- note the string, use tostring() if needed

    return result
```

If you want to use this script for collecting metrics, you could do this by just set `script.configmap` to the name of the configmap (e.g. `prometheus-redis-exporter-script`) and `script.keyname` to the configmap-key holding the script (eg. `script`). The required variables inside the container will be set automatically.
