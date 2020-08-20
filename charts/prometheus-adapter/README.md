# Prometheus Adapter

Installs the [Prometheus Adapter](https://github.com/DirectXMan12/k8s-prometheus-adapter) for the Custom Metrics API. Custom metrics are used in Kubernetes by [Horizontal Pod Autoscalers](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to scale workloads based upon your own metric pulled from an external metrics provider like Prometheus. This chart complements the [metrics-server](https://github.com/helm/charts/tree/master/stable/metrics-server) chart that provides resource only metrics.

## Prerequisites

Kubernetes 1.14+

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-adapter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-adapter
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
$ helm inspect values prometheus-community/prometheus-adapter

# Helm 3
$ helm show values prometheus-community/prometheus-adapter
```

### Prometheus Service Endpoint

To use the chart, ensure the `prometheus.url` and `prometheus.port` are configured with the correct Prometheus service endpoint. If Prometheus is exposed under HTTPS the host's CA Bundle must be exposed to the container using `extraVolumes` and `extraVolumeMounts`.

### Adapter Rules

Additionally, the chart comes with a set of default rules out of the box but they may pull in too many metrics or not map them correctly for your needs. Therefore, it is recommended to populate `rules.custom` with a list of rules (see the [config document](https://github.com/DirectXMan12/k8s-prometheus-adapter/blob/master/docs/config.md) for the proper format).

### Horizontal Pod Autoscaler Metrics

Finally, to configure your Horizontal Pod Autoscaler to use the custom metric, see the custom metrics section of the [HPA walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics).

The Prometheus Adapter can serve three different [metrics APIs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-metrics-apis):

### Custom Metrics

Enabling this option will cause custom metrics to be served at `/apis/custom.metrics.k8s.io/v1beta1`. Enabled by default when `rules.default` is true, but can be customized by populating `rules.custom`:

```yaml
rules:
  custom:
  - seriesQuery: '{__name__=~"^some_metric_count$"}'
    resources:
      template: <<.Resource>>
    name:
      matches: ""
      as: "my_custom_metric"
    metricsQuery: sum(<<.Series>>{<<.LabelMatchers>>}) by (<<.GroupBy>>)
```

### External Metrics

Enabling this option will cause external metrics to be served at `/apis/external.metrics.k8s.io/v1beta1`. Can be enabled by populating `rules.external`:

```yaml
rules:
  external:
  - seriesQuery: '{__name__=~"^some_metric_count$"}'
    resources:
      template: <<.Resource>>
    name:
      matches: ""
      as: "my_external_metric"
    metricsQuery: sum(<<.Series>>{<<.LabelMatchers>>}) by (<<.GroupBy>>)
```

### Resource Metrics

Enabling this option will cause resource metrics to be served at `/apis/metrics.k8s.io/v1beta1`. Resource metrics will allow pod CPU and Memory metrics to be used in [Horizontal Pod Autoscalers](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) as well as the `kubectl top` command. Can be enabled by populating `rules.resource`:

```yaml
rules:
  resource:
    cpu:
      containerQuery: sum(rate(container_cpu_usage_seconds_total{<<.LabelMatchers>>}[3m])) by (<<.GroupBy>>)
      nodeQuery: sum(rate(container_cpu_usage_seconds_total{<<.LabelMatchers>>, id='/'}[3m])) by (<<.GroupBy>>)
      resources:
        overrides:
          instance:
            resource: node
          namespace:
            resource: namespace
          pod:
            resource: pod
      containerLabel: container
    memory:
      containerQuery: sum(container_memory_working_set_bytes{<<.LabelMatchers>>}) by (<<.GroupBy>>)
      nodeQuery: sum(container_memory_working_set_bytes{<<.LabelMatchers>>,id='/'}) by (<<.GroupBy>>)
      resources:
        overrides:
          instance:
            resource: node
          namespace:
            resource: namespace
          pod:
            resource: pod
      containerLabel: container
    window: 3m
```

**NOTE:** Setting a value for `rules.resource` will also deploy the resource metrics API service, providing the same functionality as [metrics-server](https://github.com/helm/charts/tree/master/stable/metrics-server). As such it is not possible to deploy them both in the same cluster.
