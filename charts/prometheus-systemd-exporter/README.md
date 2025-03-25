# Prometheus Systemd Exporter

Prometheus exporter for systemd units, written in Go.

This chart bootstraps a prometheus [systemd exporter](https://github.com/prometheus-community/systemd_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Add Helm Chart Repository

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-systemd-exporter
```

_See [configuration](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-systemd-exporter
```

### Exported Systemd units

Default values generate metrics for `kubelet.service` and `docker.service` systemd units.

Units to generate metrics for are configurable by means of `config.systemd.collector.unitInclude`.

To generate metrics for all units override default values with:

```yaml
config:
  systemd:
    collector:
      unitInclude:
        - '.+'
```
