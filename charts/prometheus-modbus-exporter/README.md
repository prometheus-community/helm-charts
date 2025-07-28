# prometheus-modbus-exporter

Prometheus exporter for scraping metrics via modbus based protocol.

## Intro

This chart bootstraps a [modbus_exporter](https://github.com/RichiH/modbus_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

The serviceMonitor objects are created for Prometheus Operator.

## Configuration

The configuration of the modbus_exporter can be provided either via helm's custom values, or via an already existing (independently managed) configMap.  
Either way, every time the configuration is getting updated, the modbus_exporter is getting restarted in order to fetch it. This is done using sidecar reloader: <https://github.com/Pluies/config-reloader-sidecar>.

## Tests

This setup has been tested with both real unit (Janitza Power Analizer UMG series) as well as using an simulator <https://www.modbustools.com/download.html>.  
Other simulators (fully free) exist as well:

1. the one included as part of the test (fake server) in the <https://github.com/RichiH/modbus_exporter/blob/main/tests/fake_server/main.go>, which uses <https://github.com/tbrandon/mbserver> (Go).  
2. Many others, like pymodslave, based on py module: <https://github.com/ljean/modbus-tk>, which has its own demo simulator as well.  

## Notes

There are 4 types of read registries, hence 4 read function codes (1,2,3,4).  
Don't forget to prefix (first digit) your registry with the required function.  
Your address should be always 6 digits.  
E.g. for holding registry 22, the address is: 300022  (where the 3 denotes the holding registry function).  
More on Modbus function codes: <https://ozeki.hu/p_5873-modbus-function-codes.html>

## Prerequisites

- Kubernetes 1.10+ with Beta APIs enabled
- Helm 3+

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-modbus-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-modbus-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-modbus-exporter
```

_See [configuration](## Configuring) below._

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

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-modbus-exporter
```

For more information please refer to the [modbus_exporter](https://github.com/RichiH/modbus_exporter) documentation.
