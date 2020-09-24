# Alertmanager

As per [prometheus.io documentation](https://prometheus.io/docs/alerting/latest/alertmanager/):
> The Alertmanager handles alerts sent by client applications such as the
> Prometheus server. It takes care of deduplicating, grouping, and routing them
> to the correct receiver integration such as email, PagerDuty, or OpsGenie. It
> also takes care of silencing and inhibition of alerts.

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
$ helm install [RELEASE_NAME] prometheus-community/alertmanager

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/alertmanager
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
$ helm inspect values prometheus-community/alertmanager

# Helm 3
$ helm show values prometheus-community/alertmanager
```
