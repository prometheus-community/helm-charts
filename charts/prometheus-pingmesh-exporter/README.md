# Prometheus Pingmesh Exporter

[pingmesh architecture](https://kubeservice.cn/2022/10/21/devops-k8s-pingmesh/)

An Prometheus exporter that exposes information from ping message.

This chart creates a [Pingmesh Exporter](https://github.com/kubeservice-stack/pingmesh-agent) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-pingmesh-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-pingmesh-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-pingmesh-exporter
```

_See [configuration](#configuration) below._

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

#### From 0.22.0 to 1.0.1

```console
helm upgrade [RELEASE_NAME] prometheus-pingmesh-exporter --version 1.0.1
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values oci://ghcr.io/prometheus-community/charts/prometheus-pingmesh-exporter

# Helm 3
$ helm show values oci://ghcr.io/prometheus-community/charts/prometheus-pingmesh-exporter
```

See [kubeservice-stack/pingmesh-agent/README.md](https://github.com/kubeservice-stack/pingmesh-agent) for further information.

## pingmesh pinglist configuration

```console
setting:
  # the maximum amount of concurrent to ping, uint
  concurrent_limit: 20
  # interval to exec ping in seconds, float
  interval: 60.0
  # The maximum delay time to ping in milliseconds, float
  delay: 200
  # ping timeout in seconds, float
  timeout: 2.0
  # send ip addr
  source_ip_addr: 0.0.0.0
  # send ip protocal
  ip_protocol: ip6

mesh:
  add-ping-public: 
    name: ping-public-demo
    type: OtherIP
    ips :
      - 127.0.0.1
      - 8.8.8.8
      - kubernetes.default.svc.cluster.local
```
