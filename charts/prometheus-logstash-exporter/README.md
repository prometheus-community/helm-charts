# Logstash Exporter

Prometheus exporter for metrics provided by Node Stats API of Logstash.

Learn more: <https://github.com/alxrem/prometheus-logstash-exporter>

This chart creates an logstash-exporter deployment on a [Kubernetes](http://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.10+

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/prometheus-logstash-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/prometheus-logstash-exporter
```

The command deploys Logstash Exporter on the Kubernetes cluster using the default configuration.

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

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).
To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values prometheus-community/prometheus-logstash-exporter

# Helm 3
$ helm show values prometheus-community/prometheus-logstash-exporter
```

> **Tip**: You can use the default [values.yaml](values.yaml)
