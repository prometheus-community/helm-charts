# prometheus-statsd-exporter

The [prometheus-statsd-exporter](https://github.com/prometheus/statsd_exporter) receives StatsD metrics and exports them as Prometheus metrics.

## Introduction

This chart creates a `prometheus-statsd-exporter` deployment using the [Helm](https://helm.sh) package manager.


## Prerequisites

- Kubernetes 1.16 or above
- `prometheus-statsd-exporter` `v0.16.0`


## Installing the Chart

The `prometheus-statsd-exporter` chart is stored in the `niclic` repository.

Add the `niclic` repository to your list of helm repositories.

```sh
helm repo add niclic https://niclic.github.com/helm-charts

# review the list of avaialble charts
helm search repo niclic
NAME                              CHART VERSION APP VERSION DESCRIPTION                           
niclic/prometheus-statsd-exporter 0.1.0         0.16.0      StatsD to Prometheus metrics exporter.
```

To install the chart with the release name `prometheus-statsd-exporter` and default values:

```sh
helm install prometheus-statsd-exporter niclic/prometheus-statsd-exporter
```


## Testing the Chart.

To run the tests for this chart.

```sh
helm test prometheus-statsd-exporter
```


## Uninstalling the Chart

To uninstall `prometheus-statsd-exporter`:

```sh
helm uninstall prometheus-statsd-exporter
```


## Configuration

The following table lists the configurable parameters of the `prometheus-statsd-exporter` chart and their default values.


|             Parameter               |            Description                   |                    Default                |
|-------------------------------------|------------------------------------------|-------------------------------------------|
| `replicaCount`                      | Number of pods to run                    | `1`                                       |
| `image.repository`                  | The docker image to run                  | `prom/statsd-exporter`                    |
| `image.tag`                         | The image tag to pull                    | `v0.16.0`                                 |
| `image.pullPolicy`                  | Image pull policy                        | `IfNotPresent`                            |
| `imagePullSecrets`                  | Image pull secrets                       | `[]`                                      |
| `serviceAccount.create`             | Create a service account                 | `true`                                    |
| `podAnnotations`                    | Annotations to add to pods               | `{}`                                      |
| `priorityClassName`                 | Priority class name                      | `""`                                      |
| `podSecurityContext`                | Security settings for the pod            | `{}`                                      |
| `securityContext`                   | Security settings for the container      | `{}`                                      |
| `service.type`                      | Type of kubernetes service               | `ClusterIP`                               |
| `webPort`                           | Web port for metrics endpoint            | `9102`                                    |
| `udpPort`                           | UDP port to receive statsd metrics       | `9125`                                    |
| `tcpPort`                           | TCP port to receive statsd metrics       | `9125`                                    |
| `ingress.enabled`                   | Create an ingress resource               | `false`                                   |
| `resources`                         | Pod resource requests & limits           | `{}`                                      |
| `nodeSelector`                      | Node labels for pod assignment           | `{}`                                      |
| `affinity`                          | Node affinity for pod assignment         | `{}`                                      |
| `tolerations`                       | Node tolerations for pod assignment      | `[]`                                      |
| `statsdMappingConfig`               | `statsd-exporter` mappings               | `timer_type: histogram`                   |


Specify each parameter you'd like to override using a YAML file.

```sh
helm install prometheus-statsd-exporter niclic/prometheus-statsd-exporter -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

You can also override specific values by using the `--set key=value[,key=value]` argument to `helm install`. For example, to change the `udpPort` to `8125`:

```sh
helm install prometheus-statsd-exporter niclic/prometheus-statsd-exporter --set udpPort=8125
```


## Metric Mapping and Configuration
This chart provides a minimal default configuration. To create a custom mapping configuration and review default settings, consult the [official docs](https://github.com/prometheus/statsd_exporter#metric-mapping-and-configuration).
