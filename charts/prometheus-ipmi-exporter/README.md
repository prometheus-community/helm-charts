# Prometheus IPMI Exporter

A Prometheus exporter for *IP Management Interface* metrics.

This chart creates a [IPMI Exporter](https://github.com/prometheus-community/ipmi_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.33+

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-ipmi-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-ipmi-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-ipmi-exporter
```

*See [configuration](#configuration) below.*

*See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.*

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

*See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation.*

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

*See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.*

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-ipmi-exporter
```

### ScrapeConfig vs ServiceMonitor

This chart supports both ServiceMonitor (v1) and ScrapeConfig (v1alpha1) from prometheus-operator.

**ScrapeConfig** is recommended for:

- Scraping IPMI targets in remote mode (exporter as a proxy)
- Using file-based service discovery
- More flexibility with relabeling

**Example - Remote IPMI scraping:**

```yaml
scrapeConfig:
  enabled: true
  mode: remote  # Uses /ipmi endpoint with target relabeling
  staticConfigs:
    - targets:
        - 192.168.1.10
        - 192.168.1.11
```

**Example - Local exporter metrics:**

```yaml
scrapeConfig:
  enabled: true
  mode: local  # Uses /metrics endpoint directly
  staticConfigs:
    - targets:
        - ipmi-exporter:9290
```
