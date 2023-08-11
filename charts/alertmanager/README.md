# Alertmanager

As per [prometheus.io documentation](https://prometheus.io/docs/alerting/latest/alertmanager/):
> The Alertmanager handles alerts sent by client applications such as the
> Prometheus server. It takes care of deduplicating, grouping, and routing them
> to the correct receiver integration such as email, PagerDuty, or OpsGenie. It
> also takes care of silencing and inhibition of alerts.

## Prerequisites

Kubernetes 1.14+

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/alertmanager
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
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 1.0

The [configmap-reload](https://github.com/jimmidyson/configmap-reload) container was replaced by the [prometheus-config-reloader](https://github.com/prometheus-operator/prometheus-operator/tree/main/cmd/prometheus-config-reloader).
Extra command-line arguments specified via configmapReload.prometheus.extraArgs are not compatible and will break with the new prometheus-config-reloader, refer to the [sources](https://github.com/prometheus-operator/prometheus-operator/blob/main/cmd/prometheus-config-reloader/main.go) in order to make the appropriate adjustment to the extea command-line arguments.
The `networking.k8s.io/v1beta1` is no longer supported. use [`networking.k8s.io/v1`](https://kubernetes.io/docs/reference/using-api/deprecation-guide/#ingressclass-v122).

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/alertmanager
```
