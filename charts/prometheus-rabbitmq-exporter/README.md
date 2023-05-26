# prometheus-rabbitmq-exporter

Prometheus Exporter for [RabbitMQ](https://www.rabbitmq.com/) metrics.

This chart bootstraps a [RabbitMQ Exporter](https://github.com/kbudde/rabbitmq_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`]](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-rabbitmq-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-rabbitmq-exporter
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
$ helm inspect values prometheus-community/prometheus-rabbitmq-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-rabbitmq-exporter
```

### RabbitMQ Connection

- To configure RabbitMQ connection by value, set `rabbitmq.url`, `rabbitmq.user` and `rabbitmq.password` (see additional options in the `rabbitmq` configuration block)
- To configure RabbitMQ password by secret, you must store the password string in a secret, and set `rabbitmq.existingPasswordSecret` to `[SECRET_NAME]`
